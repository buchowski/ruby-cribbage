require "json"
require "optparse"
require "openai"
require_relative "game"

class HumanVsAiRunner
  MODEL = "gpt-5-nano"
  USAGE = "Usage: ruby lib/cribbage_game/play_with_ai.rb [--name NAME] [--players 2|3]"

  DISCARD_TOOL = {
    "type" => "function",
    "name" => "discard",
    "description" => "Discard the required number of cards from the player's hand",
    "parameters" => {
      "type" => "object",
      "properties" => {
        "card_ids" => {
          "type" => "array",
          "items" => {"type" => "string"},
          "description" => "The card identifiers to discard"
        }
      },
      "required" => ["card_ids"],
      "additionalProperties" => false
    }
  }.freeze

  PLAY_CARD_TOOL = {
    "type" => "function",
    "name" => "play_card",
    "description" => "Play one legal card from the player's hand",
    "parameters" => {
      "type" => "object",
      "properties" => {
        "card_id" => {
          "type" => "string",
          "description" => "A card identifier such as 5h, kd, or 10s"
        }
      },
      "required" => ["card_id"],
      "additionalProperties" => false
    }
  }.freeze

  def initialize(number_of_players: 2, name: nil, client: nil, input: $stdin, output: $stdout)
    unless [2, 3].include?(number_of_players)
      raise ArgumentError, "number_of_players must be either 2 or 3"
    end

    @number_of_players = number_of_players
    @human_name = name.to_s.strip
    @human_name = "Human Player" if @human_name.empty?
    @client = client || OpenAI::Client.new(
      access_token: ENV.fetch("OPENAI_API_KEY"),
      log_errors: true
    )
    @input = input
    @output = output
  end

  def self.from_argv(arguments)
    options = {name: nil, number_of_players: 2}
    parser = OptionParser.new do |opts|
      opts.banner = USAGE
      opts.on_tail("-h", "--help", "Show available options") do
        puts opts
        exit
      end
      opts.on("--name NAME", String, "Human player's name (default: Human Player)") { |name| options[:name] = name }
      opts.on("--players COUNT", Integer, "Number of players (2 or 3; default: 2)") do |count|
        options[:number_of_players] = count
      end
      opts.on("--number-of-players COUNT", Integer, "Alias for --players (default: 2)") do |count|
        options[:number_of_players] = count
      end
    end

    remaining_arguments = parser.parse!(arguments.dup)
    raise ArgumentError, "Unexpected arguments: #{remaining_arguments.join(" ")}" unless remaining_arguments.empty?

    new(**options)
  rescue OptionParser::ParseError, ArgumentError => error
    raise ArgumentError, "#{error.message}\n#{USAGE}"
  end

  def run
    game = CribbageGame::Game.new(number_of_players: @number_of_players)
    human = game.players.first
    human.name = @human_name
    @human_player = human

    game.cut_for_deal
    until game.fsm.game_over?
      announce_round(game, human)
      game.deal
      discard_hands(game, human)
      game.flip_top_card
      log("Cut card: #{game.cut_card}")
      play_cards(game, human)
      break if game.fsm.game_over?

      log("")
      score_round(game)
      log("")
    end

    log("Game over. Winner: #{player_label(game.winner)}")
    game
  end

  private

  def discard_hands(game, human)
    game.players.each do |player|
      count = game.is_three_player_game? ? 1 : 2
      if player == human
        human_discard(player, count)
      else
        ai_discard(player, count)
      end
    end
  end

  def human_discard(player, count)
    loop do
      ids = prompt("Your hand: #{available_cards(player).join(", ")}\nDiscard #{count} card#{"s" if count > 1}: ")
        .split(/[\s,]+/)
        .reject(&:empty?)

      if ids.size == count && ids.uniq.size == count && ids.all? { |id| player.hand[id] }
        player.discard(ids)
        return
      end

      log("Please enter exactly #{count} card IDs from your hand.")
    end
  end

  def ai_discard(player, count)
    arguments = ai_tool_arguments(
      player,
      DISCARD_TOOL,
      "Choose #{count} cards to discard from your hand: #{available_cards(player).join(", ")} ."
    ) do |data|
      ids = data["card_ids"]
      ids.is_a?(Array) && ids.size == count && ids.uniq.size == count && ids.all? { |id| player.hand[id] }
    end

    ids = arguments.fetch("card_ids")
    log("#{player_label(player)} discards: #{ids.join(", ")}")
    player.discard(ids)
  end

  def play_cards(game, human)
    while game.fsm.playing? && !game.player_hands_empty?
      player = game.whose_turn
      playable = available_cards(player).select { |id| game.can_play_card?(id) }

      card_id = if player == human
        prompt_for_play(game, player, playable)
      else
        ai_play(game, player, playable)
      end

      pile_was_active = !game.pile.empty?
      pile_total_after_play = game.pile_score + game.deck.fetch(card_id).value
      game.play_card(player, card_id)
      play_score = game.scorecards.fetch(game.round).fetch(:play).last
      log("#{player_label(player)} played #{card_id}; pile total #{pile_total_after_play}")
      if play_score[:points] > 0
        log("#{player_label(player)} scored #{play_score[:points]} point#{"s" if play_score[:points] != 1} during play: #{format_score_reasons(play_score[:reasons])}.")
      end
      if pile_was_active && game.pile.empty?
        log("")
      end
    end
  end

  def prompt_for_play(game, player, playable)
    loop do
      card_id = prompt(
        "Your cards: #{available_cards(player).join(", ")} " \
        "(playable: #{playable.join(", ")}; pile: #{game.pile_score})\nPlay card: "
      ).strip.downcase
      return card_id if playable.include?(card_id)

      log("Choose one of the playable cards: #{playable.join(", ")}.")
    end
  end

  def ai_play(game, player, playable)
    arguments = ai_tool_arguments(
      player,
      PLAY_CARD_TOOL,
      "Choose one card to play. Playable cards: #{playable.join(", ")}. " \
      "Current pile total: #{game.pile_score}."
    ) { |data| playable.include?(data["card_id"]) }

    arguments.fetch("card_id")
  end

  def score_round(game)
    round_scorecard = game.scorecards.fetch(game.round)
    pegging_scores = round_scorecard.fetch(:play, []).group_by { |play| play.fetch(:player_id) }
    scoring_players = [game.opponent]
    scoring_players << game.opponent_2 if game.is_three_player_game?
    scoring_players << game.dealer

    scoring_players.each do |player|
      pegging_points = pegging_scores.fetch(player.id, []).sum { |play| play.fetch(:points) }
      log("#{player_label(player)} pegging score: #{pegging_points} point#{"s" if pegging_points != 1}.")
      hand_score = round_scorecard.fetch(player.id).fetch(:hand).fetch(:total_score)
      log("#{player_label(player)} hand score: #{hand_score} point#{"s" if hand_score != 1}.")
      game.submit_hand_scores(player)
    end
    crib_owner = game.dealer
    crib_score = round_scorecard.fetch(crib_owner.id).fetch(:crib).fetch(:total_score)
    game.submit_crib_scores
    log("#{player_label(crib_owner)} crib score: #{crib_score} point#{"s" if crib_score != 1}.")
    log("Player totals: #{game.players.map { |player| "#{player_label(player)}: #{player.total_score}" }.join(", ")}")
  end

  def ai_tool_arguments(player, tool, input)
    3.times do |attempt|
      log("#{player_label(player)} input: #{input}")
      response = @client.responses.create(
        parameters: {
          model: MODEL,
          input: input,
          tools: [tool],
          tool_choice: "required"
        }
      )
      function_call = response.dig("output")&.find { |item| item["type"] == "function_call" }
      tool_name = function_call&.fetch("name", tool["name"])
      raw_arguments = function_call&.fetch("arguments", nil)
      arguments = raw_arguments && JSON.parse(raw_arguments)
      return arguments if arguments && yield(arguments)

      log("#{player_label(player)} failed tool #{tool_name} with arguments #{arguments.inspect} (attempt #{attempt + 1}).")
    rescue JSON::ParserError, KeyError, TypeError
      log("#{player_label(player)} failed tool #{tool_name || tool["name"]} with raw arguments #{raw_arguments.inspect} (attempt #{attempt + 1}).")
    end

    raise "#{player_label(player)} failed to provide a legal action"
  end

  def announce_round(game, human)
    dealer = (game.dealer == human) ? @human_name : player_label(game.dealer)
    log("Round #{game.round}: dealer is #{dealer}.")
  end

  def player_label(player)
    return @human_name if player == @human_player

    ai_name = {"1" => "One", "2" => "Two", "0" => "Three"}.fetch(player.id, player.id)
    "AI Player #{ai_name}"
  end

  def format_score_reasons(reasons)
    reasons.map { |reason| "#{reason[:type].tr("_", " ")} (#{reason[:points]})" }.join(", ")
  end

  def available_cards(player)
    player.hand.select { |_id, available| available }.keys
  end

  def prompt(message)
    @output.print(message)
    line = @input.gets
    raise "Input ended before the game finished" if line.nil?

    line
  end

  def log(message)
    @output.puts(message)
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    HumanVsAiRunner.from_argv(ARGV).run
  rescue ArgumentError => error
    warn error.message
    exit 1
  end
end

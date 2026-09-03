require_relative "card"
require_relative "score"
require_relative "player"
require_relative "fsm"

module CribbageGame
  class NotYourTurnError < RuntimeError; end

  class NotYourCardError < RuntimeError; end

  class CardTooLargeError < RuntimeError; end

  class WrongStateError < RuntimeError; end

  class Game
    attr_accessor :players, :deck, :crib, :pile, :cut_card, :dealer, :whose_turn, :fsm, :points_to_win, :round, :winner
    attr_reader :auto_score

    def initialize args = {}
      @points_to_win = args[:points_to_win] || 121
      @auto_score = args[:is_auto_score] || true
      @game_over_cb = args[:game_over_cb] || lambda {}

      @number_of_players = args.fetch(:number_of_players, 2)
      unless [2, 3].include?(@number_of_players)
        raise ArgumentError, ':number_of_players must be either 2 or 3'
      end

      @players = @number_of_players.times.map { |id| Player.new self, id.to_s }
      @score_client = Score.new self
      @fsm = Fsm.new(self)
      @deck = self.class.get_cards_hash CardDeck::Deck.new.cards
      @round = 0
      @winner = nil

      reset_cards
    end

    def scorecards
      @score_client.scorecards
    end

    def self.get_cards_hash cards
      cards.each_with_object({}) do |card, card_map|
        card_map[card.id] = card
      end
    end

    def self.get_hand_hash card_ids
      card_ids.to_h { |id| [id, true] }
    end

    def is_three_player_game?
      @number_of_players == 3
    end

    def player_index(player)
      @players.index(player)
    end

    def next_player(player)
      current_index = player_index(player)
      @players[(current_index + 1) % @players.size]
    end

    def undealt_card_ids
      dealt_cards = @players.flat_map { |player| player.hand.keys }
      dealt_cards += @crib if @crib
      dealt_cards << @cut_card if @cut_card

      @deck.keys.difference(dealt_cards)
    end

    def opponent
      next_player(@dealer)
    end

    def opponent_2
      is_three_player_game? ? next_player(opponent) : nil
    end

    def can_play_card? card_id
      pile_score + @deck[card_id].value <= 31
    end

    def player_hands_empty?
      @players.none? { |player| player.hand.values.any? }
    end

    def has_playable_card? hand
      card_ids = hand.keys.filter { |card_id| hand[card_id] } # false has been played
      card_ids.map { |card_id| can_play_card?(card_id) }.any?
    end

    def can_player_play? player
      player.nil? ? false : has_playable_card?(player.hand)
    end

    def can_any_player_play?
      @players.any? { |player| can_player_play? player }
    end

    def pile_score
      @pile.map { |card_id| @deck[card_id].value }.sum
    end

    def all_cards_discarded?
      @players.all? { |player| player.hand.keys.size == 4 }
    end

    def is_valid_play? player, card_id
      raise WrongStateError if !@fsm.playing?
      raise NotYourTurnError if player != @whose_turn
      raise NotYourCardError if !player.hand[card_id]
      raise CardTooLargeError if !can_play_card? card_id
      true
    end

    def reset_cards
      @round += 1
      @cut_card = nil
      @crib = []
      @pile = []
      @players.each { |player| player.hand = {} }
    end

    def cut_for_deal
      raise WrongStateError if !@fsm.cutting_for_deal?

      @dealer = @players.sample
      @whose_turn = next_player(@dealer)
      @fsm.deal
    end

    def deal
      raise WrongStateError if !@fsm.dealing?

      cards_per_player = is_three_player_game? ? 5 : 6
      cards_to_draw = @players.size * cards_per_player
      # draw an extra card for the crib in three player game
      cards_to_draw += 1 if is_three_player_game?

      random_card_ids = @deck.keys.sample cards_to_draw
      @players.each do |player|
        player.hand = self.class.get_hand_hash random_card_ids.slice!(0, cards_per_player)
      end

      @crib << random_card_ids.shift if is_three_player_game?

      @fsm.discard
    end

    def play_card player, card_id
      is_valid_play?(player, card_id)

      player.hand[card_id] = false
      @pile << card_id
      is_last_card = !can_any_player_play?
      @score_client.score_play(@pile, is_last_card, player)
      @score_client.submit_play_score player
      return if we_have_a_winner?

      @pile = [] if is_last_card
      next_player = next_player(player)
      next_next_player = is_three_player_game? ? next_player(next_player) : nil
      @whose_turn =
        if can_player_play? next_player
          next_player
        elsif can_player_play? next_next_player
          next_next_player
        else
          player
        end
      @fsm.score if player_hands_empty?
    end

    def flip_top_card top_card = nil
      raise WrongStateError if !@fsm.flipping_top_card?

      @cut_card = top_card || undealt_card_ids.sample
      @whose_turn = next_player(@dealer)
      @score_client.score_crib
      @score_client.score_hands
      @fsm.play
    end

    def discard player, card_id
      raise WrongStateError if !@fsm.discarding?
      raise NotYourCardError if !player.hand[card_id]

      player.hand.delete(card_id)
      @crib << card_id

      @fsm.flip_top_card if all_cards_discarded?
    end

    def submit_hand_scores player
      raise NotYourTurnError if player == @dealer && !@fsm.scoring_dealer_hand?
      raise NotYourTurnError if player == opponent && !@fsm.scoring_opponent_hand?
      raise NotYourTurnError if player == opponent_2 && !@fsm.scoring_opponent_2_hand?

      @score_client.submit_scores player, :hand
      return if we_have_a_winner?

      @fsm.score
    end

    def submit_crib_scores
      raise WrongStateError if !@fsm.scoring_dealer_crib?

      @score_client.submit_scores @dealer, :crib
      return if we_have_a_winner?
      reset_cards
      @dealer = next_player(@dealer)
      @fsm.deal
    end

    def auto_score_hands_and_crib
      @score_client.score_hands
      @score_client.score_crib
    end

    def we_have_a_winner?
      winner = @players.select { |player| player.total_score >= @points_to_win }
      return false if winner.empty?
      raise "You can only have one winner" if winner.size > 1

      @winner = winner.first
      @fsm.declare_winner
      @game_over_cb.call
      true
    end
  end
end

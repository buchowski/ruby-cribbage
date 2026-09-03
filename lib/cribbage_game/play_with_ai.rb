require "openai"
require_relative "game"

discard_tool = {
  "type" => "function",
  "name" => "discard",
  "description" => "Discard one or two cards from the player's hand",
  "parameters" => {
    "type" => "object",
    "properties" => {
      "card_ids" => {
        "type" => ["string"],
        "description" => "One or two unique identifiers for the cards to be discarded",
      }
    },
    "required" => ["card_ids"],
    "additionalProperties" => false
  }
}
play_card_tool = {
  "type" => "function",
  "name" => "play_card",
  "description" => "Play a card from the player's hand",
  "parameters" => {
    "type" => "object",
    "properties" => {
      "card_id" => {
        "type" => "string",
        "description" => "Unique identifier for the card to be played, e.g. '5h' for 5 of hearts, 'kd' for king of diamonds, etc."
      }
    },
    "required" => ["card_id"],
    "additionalProperties" => false
  }
}

client = OpenAI::Client.new(
  access_token: ENV.fetch("OPENAI_API_KEY"),
  log_errors: true
)

def prompt_ai_to_discard(ai_player)
  hand_string = ai_player.hand.keys.join(', ')
  input = "Which two of the following cards would you like to discard: #{hand_string}?"
  puts "input to model: #{input}"

  response = client.responses.create(
    parameters: {
      model: "gpt-5-nano",
      input:  input,
      tools: [discard_tool],
      tool_choice: "required"
    }
  )
  # puts response
  # puts response.dig("choices", 0, "message", "content")

  # Extract card_ids from the function_call output
  function_call = response.dig("output")&.find { |o| o["type"] == "function_call" }
  card_ids = JSON.parse(function_call&.dig("arguments")).dig("card_ids")
  puts "AI player discards: #{card_ids}"
end



def init_game
  # puts "Would you like to create a 2 or 3 player game of cribbage?"
  # response = gets.chomp
  # number_of_players = response.to_i
  number_of_players = 2 # default to 2 players for now

  game = CribbageGame::Game.new(number_of_players: number_of_players)
  human_player = game.players.first
  ai_players = game.players[1..-1]
  game.cut_for_deal
  if human_player == game.dealer
    puts "You are the dealer. Dealing now"
  else
    puts "AI player is the dealer. Dealing now"
  end
  game.deal
end

init_game()

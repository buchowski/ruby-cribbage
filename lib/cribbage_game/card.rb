module CribbageGame
  require "card_deck"

  class CardDeck::Card # Represents a card in the deck
    # Value of the card
    def value
      case @num
      when "Ace" then 1
      when 2..10 then @num
      when "Jack" then 10
      when "Queen" then 10
      when "King" then 10
      when "Joker" then 10
      end
    end

    def sort_value
      case @num
      when "Ace" then 1
      when 2..10 then @num
      when "Jack" then 11
      when "Queen" then 12
      when "King" then 13
      when "Joker" then 14
      end
    end

    def id
      suit = case @suit
      when Hearts then "h"
      when Spades then "s"
      when Diamonds then "d"
      when Clubs then "c"
      end
      num = case @num
      when "Ace" then "a"
      when "Jack" then "j"
      when "Queen" then "q"
      when "King" then "k"
      when "Joker" then "r"
      else @num.to_s
      end

      num + suit
    end
  end
end

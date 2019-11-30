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
end
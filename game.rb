require './card'

class Game
	attr_accessor :players, :deck

	def initialize args
		@players = args[:players]
		@dealer = @players.first
		@deck = CardDeck::Deck.new
		@crib = []

		deal
	end

	def deal
		@deck.cards.shuffle!
		@players.each do |player|
			player.hand = @deck.cards.slice!(0, 6)
		end
	end

	def add_card_to_crib player, card
		@crib << card
		player.hand = player.hand - [card]
	end
end
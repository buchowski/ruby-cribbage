require './card'

class Game
	attr_accessor :players, :deck, :crib, :pile

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@dealer = @players.first
		@deck = CardDeck::Deck.new
		@crib = []
		@pile = []
	end

	def deal
		@deck.cards.shuffle!
		@players.each do |player|
			player.hand = @deck.cards.slice!(0, 6)
		end
	end

	def add_card_to_crib card
		@crib << card
	end

	def add_card_to_pile card
		@pile << card
	end
end
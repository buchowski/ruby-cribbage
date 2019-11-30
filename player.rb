class Player
	attr_accessor :name, :hand

	def initialize name, game
		@name = name
		@game = game
		@hand = []
	end

	def add_card_to_crib card 
		@game.add_card_to_crib card
		@hand = @hand - [card]
	end
end
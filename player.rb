class Player
	attr_accessor :name, :hand, :score

	def initialize name, game
		@name = name
		@game = game
		@hand = []
		@score = 0
	end

	def add_card_to_crib card 
		@game.add_card_to_crib card
		@hand = @hand - [card]
	end

	def add_card_to_pile card
		@score += @game.add_card_to_pile card
		@hand = @hand - [card]
	end
end
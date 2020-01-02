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
		@game.play_card self, card
	end

	def score_hand
		@game.score_cards @hand
	end
end
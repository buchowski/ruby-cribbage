class Player
	attr_accessor :hand

	def initialize game
		@game = game
		@hand = []
	end

	def discard cards
		[cards].flatten.each do |card| 
			@game.discard self, card
		end
	end

	def play_card card
		@game.play_card self, card
	end

	def score_hand
		@game.score_hand self
	end
end
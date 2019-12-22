require './card'
require './score'

class PileError < StandardError; end
class Game
	attr_accessor :players, :deck, :crib, :pile, :pile_score, :cut_card

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@dealer = @players.first
		@deck = CardDeck::Deck.new
		@crib = []
		@pile = []
		@pile_score = 0
		@score_client = Score.new
	end

	def deal
		@deck.cards.shuffle!
		@players.each do |player|
			player.hand = @deck.cards.slice!(0, 6)
		end
		@cut_card = @deck.cards.slice!(0)
	end

	def add_card_to_crib card
		@crib << card
	end

	def add_card_to_pile card
		update_pile_score card
		@pile << card
		@score_client.get_points_for_player @pile_score
	end

	def update_pile_score card
		updated_score = @pile_score + card.value
		raise PileError if updated_score > 31
		@pile_score = updated_score
	end
end
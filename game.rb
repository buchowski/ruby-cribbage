require './card'
require './score'
require './fsm'

class PileError < StandardError; end
class Game
	attr_accessor :players, :deck, :crib, :pile, :pile_score, :cut_card, :dealer

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@dealer = @players.first
		@fsm = FSM.new self
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
		# two for his heels
		@dealer.score = 2 if @cut_card.num == "Jack"
	end

	def add_card_to_crib card
		@crib << card
	end

	def score_cards cards
		@score_client.score_hand(cards + [@cut_card])
	end

	def score_crib
		score_cards @crib
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

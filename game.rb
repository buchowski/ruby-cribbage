require './card'
require './score'

class Game
	attr_accessor :players, :deck, :crib, :pile, :pile_score, :cut_card, :dealer

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
	end

	def cut_for_top_card
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
		return false, 0 if not can_play_card? card
		@pile_score += card.value
		@pile << card
		points = @score_client.get_points_for_player @pile_score
		return true, points
	end

	def can_play_card? card
		@pile_score + card.value <= 31
	end

	def player_hands_empty?
		@players.map { |player| player.hand.empty? }.all?
	end

	def pile_has_cards?
		!@pile.empty?
	end
end

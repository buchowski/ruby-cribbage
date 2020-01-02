require './card'
require './score'

class Game
	attr_accessor :players, :deck, :crib, :pile, :pile_score, :cut_card, :dealer, :whose_turn

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@dealer = @players.first
		@deck = CardDeck::Deck.new
		@crib = []
		@pile = []
		@pile_score = 0
		@score_client = Score.new
		@whose_turn = dealer
	end

	def opponent
		@players.difference([@dealer]).first
	end

	def not_whose_turn
		@players.difference([@whose_turn]).first
	end

	def deal
		@deck.cards.shuffle!
		@players.each do |player|
			player.hand = @deck.cards.slice!(0, 6)
		end
	end

	def play_card player, card
		is_valid_play?(player, card)

		@pile_score += card.value
		player.hand = player.hand - [card]
		@pile << card
		# giving 2 for 31 twice? need to score entire pile not just pile_score
		# pass can_either_player_play? to this to score last card
		points = @score_client.get_points_for_player @pile_score 
		player.score += points

		reset_pile if not can_either_player_play?
		begin_scoring_round if not can_either_player_play?

		@whose_turn = not_whose_turn if can_not_whose_turn_play?

		return true
	end

	def is_valid_play? player, card
		raise "player must wait turn" if not player == @whose_turn
		raise "player may only play card from own hand" if not player.hand.include?(card)
		raise "cannot play card that pushes pile over 31" if not can_play_card? card
		return true
	end

	def begin_scoring_round
		# if neither player can play after reset_pile, then time for scoring round
	end

	def has_playable_card? score, cards
		cards.map { |card| card.value + score <= 31 } .any?
	end

	def can_whose_turn_play?
		has_playable_card? @pile_score, @whose_turn.hand
	end

	def can_not_whose_turn_play?
		has_playable_card? @pile_score, not_whose_turn.hand
	end

	def can_either_player_play?
		can_whose_turn_play? || can_not_whose_turn_play?
	end

	def reset_pile
		@pile = []
		@pile_score = 0
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
		return points
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

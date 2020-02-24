require './card'
require './score'

class Game
	attr_accessor :players, :deck, :crib, :pile, :cut_card, :dealer, :whose_turn, :fsm

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@deck = CardDeck::Deck.new
		@crib = []
		@pile = []
		@score_client = Score.new
		@fsm = FSM.new self
	end

	def opponent
		@players.difference([@dealer]).first
	end

	def not_whose_turn
		@players.difference([@whose_turn]).first
	end

	def cut_for_deal
		@dealer = @players.shuffle.first
		@whose_turn = @dealer
	end

	def deal
		@deck.cards.shuffle!
		@players.each do |player|
			player.hand = @deck.cards.slice!(0, 6)
		end
		@fsm.discard
	end

	def play_card player, card
		is_valid_play?(player, card)

		player.hand = player.hand - [card]
		@pile << card
		is_last_card = (not can_either_player_play?)
		player.score += @score_client.get_points(@pile, pile_score, is_last_card)

		reset_pile if is_last_card
		@fsm.score if player_hands_empty?

		@whose_turn = not_whose_turn if can_not_whose_turn_play?

		return true
	end

	def is_valid_play? player, card
		raise "must be in playing state" if not @fsm.playing?
		raise "player must wait turn" if not player == @whose_turn
		raise "player may only play card from own hand" if not player.hand.include?(card)
		raise "cannot play card that pushes pile over 31" if not can_play_card? card
		return true
	end

	def has_playable_card? score, cards
		cards.map { |card| card.value + score <= 31 } .any?
	end

	def can_whose_turn_play?
		has_playable_card? pile_score, @whose_turn.hand
	end

	def can_not_whose_turn_play?
		has_playable_card? pile_score, not_whose_turn.hand
	end

	def can_either_player_play?
		can_whose_turn_play? || can_not_whose_turn_play?
	end

	def reset_pile
		@pile = []
	end

	def pile_score
		@pile.inject(0) { |total, card| total + card.value }
	end

	def flip_top_card
		@cut_card = @deck.cards.slice!(0)
		# two for his heels
		@dealer.score = 2 if @cut_card.num == "Jack"
		@fsm.play
	end

	def all_cards_discarded?
		@players.all? { |player| player.hand.size == 4 }
	end

	def add_card_to_crib player, card
		raise "must be in discarding state" if not @fsm.discarding?
		raise "player may only play card from own hand" if not player.hand.include?(card)

		player.hand = player.hand - [card]
		@crib << card
		@fsm.flip_top_card if all_cards_discarded?
	end

	def score_hand player
		raise "not your turn" if player == @dealer && (not @fsm.scoring_dealer_hand?)
		raise "not your turn" if player == @opponent && (not @fsm.scoring_opponent_hand?)

		@fsm.score
		player.score += @score_client.score_hand(player.hand + [@cut_card])
	end

	def score_crib player
		raise "not your turn" if player != @dealer || (not @fsm.scoring_dealer_crib?)

		@fsm.score
		player.score += @score_client.score_hand(@crib + [@cut_card])
	end

	def can_play_card? card
		pile_score + card.value <= 31
	end

	def player_hands_empty?
		@players.map { |player| player.hand.empty? }.all?
	end
end

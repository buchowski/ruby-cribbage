require './card'
require './score'

class NotYourTurnError < RuntimeError; end
class CardTooLargeError < RuntimeError; end

class Game
	attr_accessor :players, :deck, :crib, :pile, :cut_card, :dealer, :whose_turn, :fsm

	def initialize args
		names = args[:names]
		@players = names.map { |name| Player.new name, self }
		@score_client = Score.new
		@fsm = FSM.new self

		reset_cards
	end

	def reset_cards
		@deck = CardDeck::Deck.new
		@crib = []
		@pile = []
		@players.each { |player| player.hand = [] }
	end

	def opponent
		@players.difference([@dealer]).first
	end

	def not_whose_turn
		@players.difference([@whose_turn]).first
	end

	def can_play_card? card
		pile_score + card.value <= 31
	end

	def player_hands_empty?
		@players.map { |player| player.hand.empty? }.all?
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

	def pile_score
		@pile.inject(0) { |total, card| total + card.value }
	end

	def all_cards_discarded?
		@players.all? { |player| player.hand.size == 4 }
	end

	def is_valid_play? player, card
		raise "must be in playing state" if not @fsm.playing?
		raise NotYourTurnError if not player == @whose_turn
		raise "player may only play card from own hand" if not player.hand.include?(card)
		raise CardTooLargeError if not can_play_card? card
		return true
	end

	def reset_pile
		@pile = []
	end

	def two_for_his_heels
		@dealer.score = 2
	end

	def cut_for_deal
		@fsm.cut_for_deal
		@dealer = @players.shuffle.first
		@whose_turn = opponent
	end

	def deal(&test_shuffle)
		@fsm.deal

		if test_shuffle.nil?
			@deck.cards.shuffle!
		else
			@deck.cards = test_shuffle.call(@deck.cards)
		end

		@dealer.hand = @deck.cards.slice!(0, 6)
		opponent.hand = @deck.cards.slice!(0, 6)

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

	def flip_top_card test_card=nil
		@fsm.flip_top_card

		if test_card.nil?
			card_index = 0
		else
			card_index = @deck.cards.index(test_card)
		end

		@cut_card = @deck.cards.slice!(card_index)
		two_for_his_heels if @cut_card.num == "Jack"
		@fsm.play
		@whose_turn = opponent
	end

	def discard player, card
		raise "must be in discarding state" if not @fsm.discarding?
		raise "player may only play card from own hand" if not player.hand.include?(card)

		player.hand = player.hand - [card]
		@crib << card
	end

	def score_hand player
		raise NotYourTurnError if player == @dealer && (not @fsm.scoring_dealer_hand?)
		raise NotYourTurnError if player == opponent && (not @fsm.scoring_opponent_hand?)

		@fsm.score
		player.score += @score_client.score_hand(player.hand + [@cut_card])
	end

	def score_crib player
		raise NotYourTurnError if player != @dealer || (not @fsm.scoring_dealer_crib?)

		player.score += @score_client.score_hand(@crib + [@cut_card])
		reset_cards
		@dealer = opponent
	end

end

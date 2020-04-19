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
		@deck = self.class.get_cards_hash CardDeck::Deck.new.cards

		reset_cards
	end

	def self.get_cards_hash cards
		cards.inject({}) do |card_map, card| 
			card_map[card.id] = card
			card_map
		end
	end

	def self.get_hand_hash card_ids
		card_ids.to_h { |id| [id, true] }
	end

	def undealt_card_ids
		@deck.keys.difference(@dealer.hand.keys, opponent.hand.keys)
	end

	def opponent
		@players.difference([@dealer]).first
	end

	def not_whose_turn
		@players.difference([@whose_turn]).first
	end

	def can_play_card? card_id
		pile_score + @deck[card_id].value <= 31
	end

	def player_hands_empty?
		@players.none? { |player| player.hand.values.any? }
	end

	def has_playable_card? hand
		card_ids = hand.keys.filter { |card_id| hand[card_id] }
		card_ids.map { |card_id| can_play_card?(card_id) } .any?
	end

	def can_whose_turn_play?
		has_playable_card? @whose_turn.hand
	end

	def can_not_whose_turn_play?
		has_playable_card? not_whose_turn.hand
	end

	def can_either_player_play?
		can_whose_turn_play? || can_not_whose_turn_play?
	end

	def pile_score
		@pile.map { |card_id| @deck[card_id].value }.sum
	end

	def all_cards_discarded?
		@players.all? { |player| player.hand.keys.size == 4 }
	end

	def is_valid_play? player, card_id
		raise "must be in playing state" if not @fsm.playing?
		raise NotYourTurnError if not player == @whose_turn
		raise "player may only play card from own hand" if not player.hand[card_id]
		raise CardTooLargeError if not can_play_card? card_id
		return true
	end

	def reset_cards
		@cut_card = nil
		@crib = []
		@pile = []
		@players.each { |player| player.hand = {} }
	end

	def cut_for_deal
		@fsm.cut_for_deal
		@dealer = @players.shuffle.first
		@whose_turn = opponent
	end

	def deal
		@fsm.deal

		random_card_ids = @deck.keys.shuffle.slice(0, 12)
		@dealer.hand = self.class.get_hand_hash random_card_ids.slice!(0, 6)
		opponent.hand = self.class.get_hand_hash random_card_ids.slice!(0, 6)

		@fsm.discard
	end

	def play_card player, card_id
		is_valid_play?(player, card_id)

		player.hand[card_id] = false
		@pile << card_id
		is_last_card = (not can_either_player_play?)

		@pile = [] if is_last_card
		@fsm.score if player_hands_empty?

		@whose_turn = not_whose_turn if can_not_whose_turn_play?
	end

	def flip_top_card
		@fsm.flip_top_card
		@cut_card = undealt_card_ids.sample 
		@whose_turn = opponent
		@fsm.play
	end

	def discard player, card_id
		raise "must be in discarding state" if not @fsm.discarding?
		raise "player may only play card from own hand" if not player.hand[card_id]

		player.hand.delete(card_id)
		@crib << card_id
	end

	def score_hand player
		raise NotYourTurnError if player == @dealer && (not @fsm.scoring_dealer_hand?)
		raise NotYourTurnError if player == opponent && (not @fsm.scoring_opponent_hand?)

		@fsm.score
	end

	def score_crib player
		raise NotYourTurnError if player != @dealer || (not @fsm.scoring_dealer_crib?)

		reset_cards
		@dealer = opponent
	end

end

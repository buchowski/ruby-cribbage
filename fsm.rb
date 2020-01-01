require 'aasm'

class FSM
	include AASM

	def initialize game
		@game = game
	end

	aasm whiny_transitions: false do
		state :waiting_to_start, initial: true
		state :cutting_for_deal, :cutting_for_top_card
		state :dealing, :scoring
		state :dealer_playing, :opponent_playing

		event :start do
			transitions from: :waiting_to_start, to: :cutting_for_deal
		end

		event :cut_for_deal do
			transitions from: :cutting_for_deal, to: :dealing
		end

		event :deal do
			transitions from: :dealing, to: :cutting_for_top_card
			after do
				@game.deal
			end
		end

		event :cut_for_top_card do
			transitions from: :cutting_for_top_card, to: :dealer_playing
			after do
				@game.cut_for_top_card
			end
		end

		event :play do
			transitions({
				from: [:dealer_playing, :opponent_playing],
				to: :scoring,
				guard: :is_play_over?
			})
			
			transitions({
				from: :dealer_playing,
				to: :opponent_playing,
				guard: [:can_dealer_play_card?, :opponent_has_playable_card?]
			})
		end
	end

	def is_play_over?
		@game.player_hands_empty? && @game.pile_has_cards?
	end

	def opponent_has_playable_card? *args
		player, card = args
		score = @game.pile_score + card.value
		@game.opponent.hand.map { |card| card.value + score <= 31 } .any?
	end

	def can_dealer_play_card? *args
		player, card = args
		@game.can_play_card? card 
	end
end
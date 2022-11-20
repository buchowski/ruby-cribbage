require 'aasm'

class Fsm
	include AASM

	aasm do
		state :cutting_for_deal, initial: true
		state :flipping_top_card
		state :discarding, :dealing, :playing
		state :scoring_opponent_hand, :scoring_dealer_hand, :scoring_dealer_crib
		state :game_over

		event :deal do
			transitions from: :cutting_for_deal, to: :dealing
			transitions from: :scoring_dealer_crib, to: :dealing
		end

		event :discard do
			transitions from: :dealing, to: :discarding
		end

		event :flip_top_card do
			transitions from: :discarding, to: :flipping_top_card
		end

		event :play do
			transitions from: :flipping_top_card, to: :playing
		end

		event :score do
			transitions from: :playing, to: :scoring_opponent_hand
			transitions from: :scoring_opponent_hand, to: :scoring_dealer_hand
			transitions from: :scoring_dealer_hand, to: :scoring_dealer_crib
		end

		event :declare_winner do
			transitions to: :game_over
		end
	end
end
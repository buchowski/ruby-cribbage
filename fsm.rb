require 'aasm'

class FSM
	include AASM

	def initialize game
		@game = game
	end

	aasm do
		state :waiting_to_start, initial: true
		state :cutting_for_deal, :cutting_for_top_card
		state :dealing

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
			transitions from: :cutting_for_top_card, to: :playing
		end
	end
end
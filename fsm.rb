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
		state :playing

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
			after do
				@game.cut_for_top_card
			end
		end

		event :play do
			transitions from: :playing, to: :scoring do
				guard do
					are_hands_empty = @game.players.map { |player| player.hand.empty?}.all?
					does_pile_have_cards = !@game.pile.empty?

					are_hands_empty && does_pile_have_cards
				end
			end
			transitions from: :playing, to: :playing
			after do |args|
				puts "bobby", args
			end
		end
	end
end
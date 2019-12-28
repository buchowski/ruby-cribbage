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
		state :player_one_playing, :player_two_playing

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
			transitions from: :cutting_for_top_card, to: :player_one_playing
			after do
				@game.cut_for_top_card
			end
		end

		event :play do
			transitions({
				from: [:player_one_playing, :player_two_playing],
				to: :scoring,
				guard: :is_play_over?
			})
			
			transitions({
				from: :player_one_playing,
				to: :player_two_playing,
				guard: :can_player_one_play_card?
			})
			transitions from: :player_one_playing, to: :player_one_playing
			transitions from: :player_two_playing, to: :player_two_playing
		end
	end

	def is_play_over?
		@game.player_hands_empty? && @game.pile_has_cards?
	end

	def can_player_one_play_card? *args
		player, card = args
		@game.can_play_card?(card) 
	end
end
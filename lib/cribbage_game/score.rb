require 'cribbage_game/score_utils'

class Score
	include ScoreUtils

	def initialize game
		@game = game
		@scorecards = {}
	end

	def get_cards card_ids
		card_ids.map { |id| @game.deck[id] }
	end

	def empty_scorecard
		{crib: {total_score: 0}, hand: {total_score: 0}}
	end

	def get_scorecard player
		@scorecards[@game.round] = @scorecards[@game.round] || {play: []}
		@scorecards[@game.round][player.id] = @scorecards[@game.round][player.id] || empty_scorecard
		@scorecards[@game.round][player.id]
	end

	def score_crib
		cards = get_cards(@game.crib + [@game.cut_card])
		get_scorecard(@game.dealer)[:crib][:total_score] = score_hand(cards, true)
	end

	def score_hands
		@game.players.each do |player|
			cards = get_cards(player.hand.keys + [@game.cut_card])
			get_scorecard(player)[:hand][:total_score] = score_hand cards
		end
	end

	def score_hand cards, is_crib=false
		n_of_kind_score = score_n_of_a_kind cards
		sum_score = score_fifteens cards
		run_score = score_hand_runs cards
		flush_score = score_flush(cards, is_crib)
		nobs_score = score_nobs(cards)
		total_score = n_of_kind_score + sum_score + run_score + flush_score + nobs_score
		total_score
	end

	def score_play pile_ids, is_last_card, player 
		@scorecards[@game.round] = @scorecards[@game.round] || {play: []}
		pile_cards = get_cards pile_ids
		points = get_pile_points(pile_cards, is_last_card) # pass pile cards not ids
		@scorecards[@game.round][:play] << {
			points: points,
			player_id: player.id,
			pile: pile_ids,
			card_id: pile_ids.last
		}
	end

	def submit_play_score player, submitted_scores=nil
		raise "You must submit scores if auto_score=false" if submitted_scores.nil? && (not @game.auto_score)

		if @game.auto_score
			player.total_score += @scorecards[@game.round][:play].last[:points]
		end
	end

	def submit_scores player, card_group, submitted_scores=nil
		raise "You must submit scores if auto_score=false" if submitted_scores.nil? && (not @game.auto_score)
		raise "card_group must be :hand or :crib" if not [:hand, :crib].include? card_group

		possible_scores = get_scorecard(player)[card_group]

		if @game.auto_score
			player.total_score += possible_scores[:total_score]
		end
	end
end
require "sum_all_number_combinations"

class Score
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
		get_scorecard(@game.dealer)[:crib][:total_score] = score_hand cards
	end

	def score_hands
		@game.players.each do |player|
			cards = get_cards(player.hand.keys + [@game.cut_card])
			get_scorecard(player)[:hand][:total_score] = score_hand cards
		end
	end

	def score_hand cards
		# return a hash with total possible score and set of all possible scores
		# 15, 31, 2k, 3k, 4k, flush, straight (small?)
		n_of_kind_score = score_n_of_a_kind cards
		sum_score = score_sums cards
		total_score = n_of_kind_score + sum_score
		total_score
	end

	def score_play pile, is_last_card, player 
		@scorecards[@game.round] = @scorecards[@game.round] || {play: []}
		points = get_pile_points(pile, is_last_card)
		@scorecards[@game.round][:play] << {
			points: points,
			player_id: player.id,
			pile: pile,
			card_id: pile.last
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

	def get_pile_points pile_ids, is_last_card
		pile_cards = get_cards pile_ids
		pile_score = pile_cards.map { |card| card.value } .sum
		points = 0
		points = 1 if pile_score == 31
		points = 2 if pile_score == 15

		points += 1 if is_last_card
		points += score_consecutive pile_cards
		
		return points
	end

	def score_consecutive cards
		count = 0

		cards.each_index do |i|
			break if i == cards.size - 1
			count = (cards[i].num == cards[i + 1].num) ? count + 1 : 0
		end
		# returns 0, 2, 6 or 12
		return count ** 2 + count
	end

	def score_n_of_a_kind cards
		# 2, 3, 4 of a kind
		counts = cards.reduce({}) do |counts, card|
			if counts[card.num].nil?
				counts[card.num] = 1
			else
				counts[card.num] += 1
			end
			counts
		end

		counts.values.reduce(0) do |points, count|
			points += count * (count - 1)
		end
	end

	def score_sums cards
		# 15 & 31
		card_values = cards.map { |card| card.value }
		sum_of_all = SumAllCombinations.new card_values
		sum_of_all.sum
		fifteen_count = sum_of_all.calculated_values.count 15.0
		thirty_one_count = sum_of_all.calculated_values.count 31.0
		fifteen_count * 2 + thirty_one_count * 2
	end
end
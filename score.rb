require "sum_all_number_combinations"

class Score
	def get_points_for_player points
		if points == 15 || points == 31
			return 2
		end
		return 0
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

	def score_hand cards
		# 15, 31, 2k, 3k, 4k, flush, straight (small?)
		n_of_kind_score = score_n_of_a_kind cards
		sum_score = score_sums cards
		total_score = n_of_kind_score + sum_score
		total_score
	end
end
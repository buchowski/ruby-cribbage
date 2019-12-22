
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
			points += (count > 1) ? count * 2 : 0
		end
	end

	def score_hand cards
		# 15, 31, 2k, 3k, 4k, flush, straight (small?)
		# include crib
		score_n_of_a_kind cards
	end
end
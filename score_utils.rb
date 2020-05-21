require "sum_all_number_combinations"

module ScoreUtils

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

	def score_fifteens cards
		card_values = cards.map { |card| card.value }
		sum_of_all = SumAllCombinations.new card_values
		sum_of_all.sum
		fifteen_count = sum_of_all.calculated_values.count 15.0

		return fifteen_count * 2
    end
    
	def get_pile_points pile_cards, is_last_card
		pile_score = pile_cards.map { |card| card.value } .sum

		throw "31 should always be is_last_card" if pile_score == 31 && (not is_last_card)

		points = 0
		points = 1 if pile_score == 31
		points = 2 if pile_score == 15

		points += 1 if is_last_card
		points += score_consecutive pile_cards
		
		return points
	end
end
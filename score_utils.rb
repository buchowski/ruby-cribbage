require "sum_all_number_combinations"


module ScoreUtils

	def is_hand_run sort_vals
		sort_vals.each_index do |i| 
			return true if i == sort_vals.size - 1
			card_val =  sort_vals[i]
			next_card_val = sort_vals[i + 1]
			is_same_card = next_card_val == card_val
			is_adj_card = next_card_val - card_val == 1
			is_run_possible = is_adj_card || is_same_card
			return false if not is_run_possible
		end
	end

	def is_pile_run cards
		cards.each_index do |i| 
			return true if i == cards.size - 1
			card_val =  cards[i].sort_value
			next_card_val = cards[i + 1].sort_value
			is_adj_card = next_card_val - card_val == 1
			return false if not is_adj_card
		end
	end

	def score_hand_runs cards
		return 0 if cards.size < 3

		by_sort_value = proc { |card| card.sort_value }
		sort_vals = cards.map(&by_sort_value).sort
		sort_vals.each_index do |i|
			(3..(sort_vals.size)).to_a.reverse.each do |n|
				subset = sort_vals[i...n]
				uniq_count = subset.uniq.size
				break if uniq_count < 3

				if is_hand_run(subset)
					points = uniq_count
					subset.uniq.each do |sort_val|
						count = subset.count sort_val
						points *= count if count > 1
					end
					return points
				end
			end
		end

		return 0
	end

	def score_pile_runs cards
		return 0 if cards.size < 3

		(3..cards.size).to_a.reverse.each do |n|
			# get the last n cards played and sort_by sort_value
			subset = cards.reverse[0...n].sort_by { |card| card.sort_value }
			return n if is_pile_run subset
		end

		return 0
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
		points += score_pile_runs pile_cards
		
		return points
	end
end
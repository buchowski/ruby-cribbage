require "sum_all_number_combinations"

module CribbageGame
  module ScoreUtils
    def is_run sort_vals, is_allow_double_runs = false
      sort_vals.each_index do |i|
        return true if i == sort_vals.size - 1
        card_val = sort_vals[i]
        next_card_val = sort_vals[i + 1]
        is_same_card = next_card_val == card_val
        is_adj_card = next_card_val - card_val == 1
        is_run_possible = is_adj_card || (is_same_card && is_allow_double_runs)
        return false if !is_run_possible
      end
    end

    def score_hand_runs cards
      return 0 if cards.size < 3

      sort_vals = cards.map(&:sort_value).sort
      sort_vals.each_index do |i|
        (3..(sort_vals.size)).to_a.reverse_each do |n|
          subset = sort_vals[i...n]
          uniq_count = subset.uniq.size
          break if uniq_count < 3

          if is_run(subset, true)
            points = uniq_count
            subset.uniq.each do |sort_val|
              count = subset.count sort_val
              points *= count if count > 1
            end
            return points
          end
        end
      end

      0
    end

    def score_pile_runs cards
      return 0 if cards.size < 3

      (3..cards.size).to_a.reverse_each do |n|
        # get the last n cards played and sort_by sort_value
        sort_vals = cards.map(&:sort_value)
        subset = sort_vals.reverse[0...n].sort
        return n if is_run subset
      end

      0
    end

    def score_consecutive cards
      count = 0

      cards.each_index do |i|
        break if i == cards.size - 1
        count = (cards[i].num == cards[i + 1].num) ? count + 1 : 0
      end
      # returns 0, 2, 6 or 12
      count**2 + count
    end

    def score_n_of_a_kind cards
      # 2, 3, 4 of a kind
      counts = cards.each_with_object({}) do |card, counts|
        if counts[card.num].nil?
          counts[card.num] = 1
        else
          counts[card.num] += 1
        end
      end

      counts.values.reduce(0) do |points, count|
        points + count * (count - 1)
      end
    end

    def score_fifteens cards
      card_values = cards.map(&:value)
      sum_of_all = SumAllCombinations.new card_values
      sum_of_all.sum
      fifteen_count = sum_of_all.calculated_values.count 15.0

      fifteen_count * 2
    end

    def are_same_suit cards
      cards.map(&:suit).uniq.size == 1
    end

    def score_flush cards, is_crib = false
      raise ArgumentError, "only pass 4 or 5 cards to score_flush" if !cards.size.between?(4, 5)
      is_five_card_flush = cards.size == 5 && are_same_suit(cards)
      is_four_card_flush = cards.size == 4 && are_same_suit(cards[0...4])

      return 5 if is_five_card_flush
      return 4 if is_four_card_flush && !is_crib
      0
    end

    def score_nobs cards
      top_card = cards.pop
      jack = cards.find { |card| card.num == "Jack" }
      return 1 if jack && jack.suit == top_card.suit
      0
    end

    def get_pile_points pile_cards, is_last_card
      pile_score = pile_cards.map(&:value).sum

      throw "31 should always be is_last_card" if pile_score == 31 && !is_last_card

      points = 0
      points = 1 if pile_score == 31
      points = 2 if pile_score == 15

      points += 1 if is_last_card
      points += score_consecutive pile_cards
      points += score_pile_runs pile_cards

      points
    end
  end
end

require './score'
require './spec/test_utils'

RSpec.describe Score, "score_client" do
	context "score_n_of_a_kind" do
		before(:example) do
			@score_client = Score.new
		end

		it "should return 0 if no score" do
			score = @score_client.score_n_of_a_kind(get_cards ["King"])
			expect(score).to eql 0
		end

		it "should return 2 for pair" do
			card_request = get_cards Array.new(2, "Queen")
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 2
		end

		it "should return 6 for 3-of-kind" do
			card_request = get_cards Array.new(3, "Ace")
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 6
		end

		it "should return 12 for 4-of-kind" do
			card_request = get_cards Array.new(4, 2)
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 12
		end
	end
end

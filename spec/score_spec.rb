require './score'
require './spec/test_utils'

RSpec.describe Score, "score_client" do
	before(:example) do
		@score_client = Score.new Game.new
		@aces = get_cards_by_num ["Ace", "Ace", "Ace"]
		@jacks = get_cards_by_num ["Jack", "Jack"]
		@fives = get_cards_by_num [5, 5, 5, 5]
	end

	context "score_n_of_a_kind" do
		it "should return 0 if no score" do
			score = @score_client.score_n_of_a_kind(get_cards_by_num ["King"])
			expect(score).to eql 0
		end

		it "should return 2 for pair" do
			card_request = get_cards_by_num Array.new(2, "Queen")
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 2
		end

		it "should return 6 for 3-of-kind" do
			card_request = get_cards_by_num Array.new(3, "Ace")
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 6
		end

		it "should return 12 for 4-of-kind" do
			card_request = get_cards_by_num Array.new(4, 2)
			score = @score_client.score_n_of_a_kind(card_request)
			expect(score).to eql 12
		end
	end
	context "score_consecutive" do
		before do
			@cards = [@aces.first, @fives.first, @jacks.first]
		end
		it "should return 0 for 0 in a row" do
			expect(@score_client.score_consecutive @cards).to eql 0
		end
		it "should return 2 for 2 in a row" do
			cards = @cards + [@fives.first]
			expect(@score_client.score_consecutive cards).to eql 0
		end
		it "should return 6 for 3 in a row" do
			expect(@score_client.score_consecutive @aces).to eql 6
		end
		it "should return 12 for 4 in a row" do
			cards = @cards + @fives
			expect(@score_client.score_consecutive cards).to eql 12
		end
	end
end

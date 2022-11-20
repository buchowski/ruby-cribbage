require 'score'
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
	context "get_pile_points - foreign card (extra 7h) breaks run" do
		it "should return 0 for 8" do
			cards = @score_client.get_cards ['8h']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 2 for 8, 7" do
			cards = @score_client.get_cards ['8h', '7c']
			expect(@score_client.get_pile_points cards, false).to eql 2
		end
		it "should return 2 for 8, 7, 7" do
			cards = @score_client.get_cards ['8h', '7c', '7h']
			expect(@score_client.get_pile_points cards, false).to eql 2
		end
		it "should return 0 for 8, 7, 7, 6" do
			cards = @score_client.get_cards ['8h', '7c', '7h', '6s']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
	end
	context "get_pile_points - nonsequential run" do
		it "should return 0" do
			cards = @score_client.get_cards ['9h']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 2 for 15" do
			cards = @score_client.get_cards ['9h', '6d']
			expect(@score_client.get_pile_points cards, false).to eql 2
		end
		it "should return 0" do
			cards = @score_client.get_cards ['9h', '6d', '8d']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 4 for run" do
			cards = @score_client.get_cards ['9h', '6d', '8d', '7c']
			expect(@score_client.get_pile_points cards, false).to eql 4
		end
		it "should return 5 for run" do
			cards = @score_client.get_cards ['2h', '4d', '3d', '6c', '5h']
			expect(@score_client.get_pile_points cards, false).to eql 5
		end
		it "should return 3 for run" do
			cards = @score_client.get_cards ['jh', '9d', '10d']
			expect(@score_client.get_pile_points cards, false).to eql 3
		end
	end
	context "get_pile_points - sequential run" do
		it "should return 0" do
			cards = @score_client.get_cards ['9h']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 0" do
			cards = @score_client.get_cards ['9h', 'ad']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 0" do
			cards = @score_client.get_cards ['9h', 'ad', '2h']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
		it "should return 3 for run" do
			cards = @score_client.get_cards ['10h', 'ad', '2h', '3d']
			expect(@score_client.get_pile_points cards, false).to eql 3
		end
		it "should return 4 for run" do
			cards = @score_client.get_cards ['9h', 'ad', '2h', '3d', '4c']
			expect(@score_client.get_pile_points cards, false).to eql 4
		end
		it "should return 0" do
			cards = @score_client.get_cards ['9h', 'ad', '2h', '3d', '4c', '6d']
			expect(@score_client.get_pile_points cards, false).to eql 0
		end
	end
	context "score_hand" do
		it "should not score 31 or ace as adjacent to king" do
			cards = @score_client.get_cards ['10h', 'qd', 'kh', 'ad']
			expect(@score_client.score_hand cards).to eql 0
		end
		it "should score 15's, 3 card run and pair" do
			cards = @score_client.get_cards ['9h', 'ad', '2h', '3d', '9c']
			expect(@score_client.score_hand cards).to eql 9
		end
		it "should score 15 and run no matter the card order" do
			cards = @score_client.get_cards ['ah', '8d', '2h', '3d', '10c']
			expect(@score_client.score_hand cards).to eql 5
		end
		it "should score 15 and 3 of kind" do
			cards = @score_client.get_cards ['3h', '3d', '3c', '6d', '7c']
			expect(@score_client.score_hand cards).to eql 8
		end
		it "should score 15's and pairs" do
			cards = @score_client.get_cards ['7h', '8d', '8h', '7d', '4c']
			expect(@score_client.score_hand cards).to eql 12
		end
		it "should score 15's and 5 card run" do
			cards = @score_client.get_cards ['5h', '6d', '7h', '8d', '9c']
			expect(@score_client.score_hand cards).to eql 9
		end
	end
	context "score_hand_runs" do
		it "should score 3 card double run" do
			cards = @score_client.get_cards ['2h', '3d', '4h', '4d', '7c']
			expect(@score_client.score_hand_runs cards).to eql 6
		end
		it "should score 4 card double run" do
			cards = @score_client.get_cards ['8h', '6d', '7h', '7d', '5c']
			expect(@score_client.score_hand_runs cards).to eql 8
		end
		it "should score double-double run" do
			cards = @score_client.get_cards ['2h', '6h', '6d', '7h', '7d', '5c', '3c']
			expect(@score_client.score_hand_runs cards).to eql 12
		end
	end
	context "score_flush" do 
		it "should score 0 if all cards aren't of same suit" do
			cards = @score_client.get_cards ['8h', '6d', '7h', '7d', '5c']
			expect(@score_client.score_flush cards).to eql 0
		end
		it "should raise error 0 if 3 cards or less" do
			cards = @score_client.get_cards ['8h', '6h', '7h']
			expect { @score_client.score_flush cards }.to raise_error ArgumentError
		end
		it "should score 4 if 4 card flush" do
			cards = @score_client.get_cards ['8h', '6h', '7h', 'kh']
			expect(@score_client.score_flush cards).to eql 4
		end
		it "should score 5 if 5 card flush" do
			cards = @score_client.get_cards ['8h', '6h', '7h', 'kh', 'jh']
			expect(@score_client.score_flush cards).to eql 5
		end
	end
	context "score_nobs" do
		it "should return 0 if no jack in hand" do
			cards = @score_client.get_cards ['8h', '6d', '7h', '7d', '5c']
			expect(@score_client.score_nobs(cards)).to eql 0
		end
		it "should return 0 if jack doesn't match top card suit" do
			cards = @score_client.get_cards ['jh', '6d', '7h', '7d', '5c']
			expect(@score_client.score_nobs(cards)).to eql 0
		end
		it "should return 1 if jack matches top card suit" do
			cards = @score_client.get_cards ['jh', '6d', '7h', '7d', '5h']
			expect(@score_client.score_nobs(cards)).to eql 1
		end
	end
end

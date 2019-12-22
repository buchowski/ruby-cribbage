require './score'
require './card'

RSpec.describe Score, "score_client" do
	context "score_n_of_a_kind" do

		score_client = Score.new
		deck = CardDeck::Deck.new

		it "should return 0 if no score" do
			score = score_client.score_n_of_a_kind(deck.cards.slice(0, 1))
			expect(score).to eql 0
		end
	end
end

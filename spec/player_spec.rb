require './game'
require './player'
require './spec/test_utils'

RSpec.describe Player, "" do
	before(:example) do
		@game = Game.new names: ["brandon", "murphy"]
		@game.cut_for_deal
		@game.deal
		non_jack_card = @game.deck.cards.filter { |card| card.num != "Jack" } .first
		@game.flip_top_card(non_jack_card)
	end

	context "#play_card" do
		it "should transition between players and update player scores" do
			ace, five, ten, five_two, ten_two = get_cards_by_num ["Ace", 5, 10, 5, 10]
			dealer, opponent = @game.whose_turn, @game.not_whose_turn
			dealer.hand = [five, ten, ace]
			opponent.hand = [ten_two, five_two]

			dealer.play_card five
			expect(dealer.score).to eql 0

			opponent.play_card ten_two
			expect(opponent.score).to eql 2

			dealer.play_card ten
			expect(dealer.score).to eql 2

			opponent.play_card five_two
			expect(opponent.score).to eql 2

			dealer.play_card ace
			expect(dealer.score).to eql 4
		end
	end
end

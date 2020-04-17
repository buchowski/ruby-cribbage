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

	context "#add_card_to_pile" do
		it "should transition between players and update player scores" do
			ace, five, ten, five_two, ten_two = get_cards ["Ace", 5, 10, 5, 10]
			dealer, opponent = @game.whose_turn, @game.not_whose_turn
			dealer.hand = [five, ten, ace]
			opponent.hand = [ten_two, five_two]

			dealer.add_card_to_pile five
			expect(dealer.score).to eql 0

			opponent.add_card_to_pile ten_two
			expect(opponent.score).to eql 2

			dealer.add_card_to_pile ten
			expect(dealer.score).to eql 2

			opponent.add_card_to_pile five_two
			expect(opponent.score).to eql 2

			dealer.add_card_to_pile ace
			expect(dealer.score).to eql 4
		end
	end
end

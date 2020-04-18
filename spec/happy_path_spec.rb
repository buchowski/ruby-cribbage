require './game'

describe "happy_path_integration" do
	before(:all) do
		@game = Game.new names: ["brandon", "murphy"]
		@deck_hash = get_cards_hash @game.deck.cards
		@game.cut_for_deal
	end

	context "first hand" do
		before(:all) do
			@dealer_cards = ["8h", "5s", "9c", "3h", "7d", "qc"]
			@opponent_cards = ["ah", "7c", "2d", "4c", "6h", "9s"]
			@flip_card = "8s"

			@game.deal do |cards|
				frontload_deck_with(cards, @dealer_cards + @opponent_cards)
			end
		end

		it "should deal to players" do
			expect(hand_ids_of @game.dealer).to eql @dealer_cards
			expect(hand_ids_of @game.opponent).to eql @opponent_cards
		end

		it "should let players discard" do
			nine, three, two, four = get_cards @deck_hash, ['9c', '3h', '2d', '4c']
			@game.dealer.discard [nine, three]
			@game.opponent.discard [two, four]

			expect(@game.dealer.hand.size).to eql 4
			expect(@game.opponent.hand.size).to eql 4
			expect(@game.crib.size).to eql 4
		end

		it "should flip_top_card" do
			@game.flip_top_card @deck_hash[@flip_card]
		end
	end

end

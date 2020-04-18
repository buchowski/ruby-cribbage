require './game'

describe "happy_path_integration" do
	before(:all) do
		@game = Game.new names: ["brandon", "murphy"]
		@deck_hash = get_cards_hash @game.deck.cards
		@game.cut_for_deal
	end

	def deal_frontloaded_deck cards
		@game.deal do |deck_cards|
			frontload_deck_with(deck_cards, cards)
		end
	end

	def get cards
		if cards.is_a? Array 
			get_cards(@deck_hash, cards)
		else
			@deck_hash[cards]
		end
	end

	context "first hand" do
		before(:all) do
			@dealer_cards = ["8h", "5s", "9c", "3h", "7d", "qc"]
			@opponent_cards = ["ah", "7c", "2d", "4c", "6h", "9s"]
			@flip_card = "8s"
			deal_frontloaded_deck(@dealer_cards + @opponent_cards)
		end

		it "should deal to players" do
			expect(hand_ids_of @game.dealer).to eql @dealer_cards
			expect(hand_ids_of @game.opponent).to eql @opponent_cards
		end

		it "should let players discard" do
			@game.dealer.discard get(["7d", "qc"])
			@game.opponent.discard get(["6h", "9s"])

			expect(@game.dealer.hand.size).to eql 4
			expect(@game.opponent.hand.size).to eql 4
			expect(@game.crib.size).to eql 4
		end

		it "should flip_top_card" do
			@game.flip_top_card get(@flip_card)
		end

		it "should let players play" do
			@game.opponent.play_card get('ah')
			@game.dealer.play_card get('8h')
			@game.opponent.play_card get('7c')
			@game.dealer.play_card get('5s')
			@game.opponent.play_card get('2d')
			expect { @game.dealer.play_card get('9c') }.to raise_error
		end
	end

end

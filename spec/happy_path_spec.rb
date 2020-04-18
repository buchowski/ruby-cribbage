require './game'

describe "happy_path_integration" do
	before(:all) do
		@game = Game.new names: ["brandon", "murphy"]
		@deck_hash = get_cards_hash @game.deck.cards
		@game.cut_for_deal
		@dealer = @game.dealer
		@opponent = @game.opponent
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
			expect(hand_ids_of @dealer).to eql @dealer_cards
			expect(hand_ids_of @opponent).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard get(["7d", "qc"])
			@opponent.discard get(["6h", "9s"])

			expect(@dealer.hand.size).to eql 4
			expect(@opponent.hand.size).to eql 4
			expect(@game.crib.size).to eql 4
		end

		it "should flip_top_card" do
			@game.flip_top_card get(@flip_card)
		end

		it "should play round 1" do
			@opponent.play_card get('ah')
			@dealer.play_card get('8h')
			@opponent.play_card get('7c')
			@dealer.play_card get('5s')
			@opponent.play_card get('2d') #23
			expect { @dealer.play_card get('9c') }.to raise_error(CardTooLargeError)
			expect { @opponent.play_card get('4c') }.to raise_error(NotYourTurnError)
			@dealer.play_card get('3h')
			@opponent.play_card get('4c') #30
		end

		it "should play round 2" do
			@dealer.play_card get('9c')
		end
	end

end
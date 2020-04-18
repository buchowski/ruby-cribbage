require './game'

describe "happy_path_integration" do
	before(:all) do
		@game = Game.new names: ["brandon", "murphy"]
		@game.cut_for_deal
	end

	def deal_frontloaded_deck cards
		@game.deal do |deck_cards|
			raise "deck is not full" if deck_cards.size != 52
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
			@dealer = @game.dealer
			@opponent = @game.opponent
			@deck_hash = get_cards_hash @game.deck.cards
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
			@opponent.play_card get('7c') #16
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

		it "should score opponent's hand" do
			expect { @game.score_hand @dealer }.to raise_error(NotYourTurnError)
			@game.score_hand @opponent
		end

		it "should score dealer's hand" do
			@game.score_hand @dealer
		end

		it "should score dealer's crib" do
			expect { @game.score_crib @opponent }.to raise_error(NotYourTurnError)
			@game.score_crib @dealer
		end
	end

	context "second hand" do
		before(:all) do
			@dealer_cards = ["2h", "9d", "7c", "2s", "kd", "6d"]
			@opponent_cards = ["10d", "ad", "jh", "5h", "4h", "5d"]
			@flip_card = "qd"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@deck_hash = get_cards_hash @game.deck.cards
			deal_frontloaded_deck(@dealer_cards + @opponent_cards)
		end

		it "should deal to players" do
			expect(hand_ids_of @dealer).to eql @dealer_cards
			expect(hand_ids_of @opponent).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard get(["kd", "6d"])
			@opponent.discard get(["4h", "5d"])
		end

		it "should flip_top_card" do
			@game.flip_top_card get(@flip_card)
		end

		it "should play round 1" do
			@opponent.play_card get('10d')
			@dealer.play_card get('2h')
			@opponent.play_card get('ad')
			@dealer.play_card get('9d') #22
			expect { @opponent.play_card get('jh') }.to raise_error(CardTooLargeError)
			@opponent.play_card get('5h')
			expect { @dealer.play_card get('7c') }.to raise_error(CardTooLargeError)
			@dealer.play_card get('2s') #29
		end

		it "should play round 2" do
			expect { @dealer.play_card get('7c') }.to raise_error(NotYourTurnError)
			@opponent.play_card get('jh')
			@dealer.play_card get('7c')
		end

		it "should scores hands and crib" do
			@game.score_hand @opponent
			@game.score_hand @dealer
			@game.score_crib @dealer
		end
	end

	context "third hand" do
		before(:all) do
			@dealer_cards = ["8c", "10s", "2c", "2h", "6s", "jd"]
			@opponent_cards = ["4h", "ks", "8h", "kh", "3c", "qd"]
			@flip_card = "3s"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@deck_hash = get_cards_hash @game.deck.cards
			deal_frontloaded_deck(@dealer_cards + @opponent_cards)
		end

		it "should deal to players" do
			expect(hand_ids_of @dealer).to eql @dealer_cards
			expect(hand_ids_of @opponent).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard get(["6s", "jd"])
			@opponent.discard get(["3c", "qd"])
		end

		it "should flip_top_card" do
			@game.flip_top_card get(@flip_card)
		end

		it "should play round 1" do
			@opponent.play_card get('4h')
			@dealer.play_card get('8c')
			@opponent.play_card get('ks') #22
			expect { @dealer.play_card get('10s') }.to raise_error(CardTooLargeError)
			@dealer.play_card get('2c')
			# opponent doesn't have a playable card since 8h and kh are too large
			expect { @opponent.play_card get('8h') }.to raise_error(NotYourTurnError)
			@dealer.play_card get('2h') # pair
		end

		it "should play round 2" do
			@opponent.play_card get('8h')
			@dealer.play_card get('10s')
			@opponent.play_card get('kh')
		end

		it "should scores hands and crib" do
			@game.score_hand @opponent
			@game.score_hand @dealer
			@game.score_crib @dealer
		end
	end
end

require './game'

describe "happy_path_integration" do
	before(:all) do
		@game_over_cb = proc {}
		@game = Game.new ({
			points_to_win: 32,
			game_over_cb: @game_over_cb
		})
		@game.cut_for_deal
	end

	context "first hand" do
		before(:all) do
			@dealer_cards = ["8h", "5s", "9c", "3h", "7d", "qc"]
			@opponent_cards = ["ah", "7c", "2d", "4c", "6h", "9s"]
			@flip_card = "8s"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@game.deal
			@dealer.hand = @dealer_cards.to_h { |id| [id, true] }
			@opponent.hand = @opponent_cards.to_h { |id| [id, true] }
		end

		it "should deal to players" do
			expect(@dealer.hand.keys).to eql @dealer_cards
			expect(@opponent.hand.keys).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard ["7d", "qc"]
			@opponent.discard ["6h", "9s"]

			expect(@dealer.hand.keys.size).to eql 4
			expect(@opponent.hand.keys.size).to eql 4
			expect(@game.crib.size).to eql 4
		end

		it "should flip_top_card" do
			@game.flip_top_card @flip_card
		end

		it "should play round 1" do
			@opponent.play_card 'ah'
			@dealer.play_card '8h'
			@opponent.play_card '7c' #16
			@dealer.play_card '5s'
			@opponent.play_card '2d' #23
			expect { @dealer.play_card '9c' }.to raise_error(CardTooLargeError)
			expect { @opponent.play_card '4c' }.to raise_error(NotYourTurnError)
			@dealer.play_card '3h'
			@opponent.play_card '4c' #30
		end

		it "should play round 2" do
			@dealer.play_card '9c'
		end

		it "should score opponent's hand" do
			expect { @game.submit_hand_scores @dealer }.to raise_error(NotYourTurnError)
			@game.submit_hand_scores @opponent
		end

		it "should score dealer's hand" do
			@game.submit_hand_scores @dealer
		end

		it "should score dealer's crib" do
			@game.submit_crib_scores
		end
	end

	context "second hand" do
		before(:all) do
			@dealer_cards = ["2h", "9d", "7c", "2s", "kd", "6d"]
			@opponent_cards = ["10d", "ad", "jh", "5h", "4h", "5d"]
			@flip_card = "qd"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@game.deal
			@dealer.hand = @dealer_cards.to_h { |id| [id, true] }
			@opponent.hand = @opponent_cards.to_h { |id| [id, true] }
		end

		it "should deal to players" do
			expect(@dealer.hand.keys).to eql @dealer_cards
			expect(@opponent.hand.keys).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard ["kd", "6d"]
			@opponent.discard ["4h", "5d"]
		end

		it "should flip_top_card" do
			@game.flip_top_card @flip_card
		end

		it "should play round 1" do
			@opponent.play_card '10d'
			@dealer.play_card '2h'
			@opponent.play_card 'ad'
			@dealer.play_card '9d' #22
			expect { @opponent.play_card 'jh' }.to raise_error(CardTooLargeError)
			@opponent.play_card '5h'
			expect { @dealer.play_card '7c' }.to raise_error(CardTooLargeError)
			@dealer.play_card '2s' #29
		end

		it "should play round 2" do
			expect { @dealer.play_card '7c' }.to raise_error(NotYourTurnError)
			@opponent.play_card 'jh'
			@dealer.play_card '7c'
		end

		it "should scores hands and crib" do
			@game.submit_hand_scores @opponent
			@game.submit_hand_scores @dealer
			@game.submit_crib_scores
		end
	end

	context "third hand" do
		before(:all) do
			@dealer_cards = ["8c", "10s", "2c", "2h", "6s", "jd"]
			@opponent_cards = ["4h", "ks", "8h", "kh", "3c", "qd"]
			@flip_card = "3s"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@game.deal
			@dealer.hand = @dealer_cards.to_h { |id| [id, true] }
			@opponent.hand = @opponent_cards.to_h { |id| [id, true] }
		end

		it "should deal to players" do
			expect(@dealer.hand.keys).to eql @dealer_cards
			expect(@opponent.hand.keys).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard ["6s", "jd"]
			@opponent.discard ["3c", "qd"]
		end

		it "should flip_top_card" do
			@game.flip_top_card @flip_card
		end

		it "should play round 1" do
			@opponent.play_card '4h'
			@dealer.play_card '8c'
			@opponent.play_card 'ks' #22
			expect { @dealer.play_card '10s' }.to raise_error(CardTooLargeError)
			@dealer.play_card '2c'
			# opponent doesn't have a playable card since 8h and kh are too large
			expect { @opponent.play_card '8h' }.to raise_error(NotYourTurnError)
			@dealer.play_card '2h' # pair
		end

		it "should play round 2" do
			@opponent.play_card '8h'
			@dealer.play_card '10s'
			@opponent.play_card 'kh'
		end

		it "should scores hands and crib" do
			@game.submit_hand_scores @opponent
			@game.submit_hand_scores @dealer
			@game.submit_crib_scores
		end
	end

	context "fourth hand" do
		before(:all) do
			@dealer_cards = ["8d", "4s", "9d", "6c", "qh", "7c"]
			@opponent_cards = ["ah", "js", "2s", "5h", "3d", "kc"]
			@flip_card = "9c"
			@dealer = @game.dealer
			@opponent = @game.opponent
			@game.deal
			@dealer.hand = @dealer_cards.to_h { |id| [id, true] }
			@opponent.hand = @opponent_cards.to_h { |id| [id, true] }
		end

		it "should deal to players" do
			expect(@dealer.hand.keys).to eql @dealer_cards
			expect(@opponent.hand.keys).to eql @opponent_cards
		end

		it "should let players discard" do
			@dealer.discard ["qh", "7c"]
			@opponent.discard ["3d", "kc"]
		end

		it "should flip_top_card" do
			@game.flip_top_card @flip_card
		end

		it "should play round 1" do
			@opponent.play_card 'ah'
			@dealer.play_card '4s'
			@opponent.play_card 'js' #15
			@dealer.play_card '8d'
			@opponent.play_card '2s'
			@dealer.play_card '6c' #31
		end

		it "should play round 2" do
			@opponent.play_card '5h'
			@dealer.play_card '9d'
		end

		it "should scores hands and crib" do
			expect(@game.fsm.game_over?).to eql false
			@game.submit_hand_scores @opponent
			expect { @game.submit_hand_scores @dealer }.to raise_error(NotYourTurnError)
			expect(@game.fsm.game_over?).to eql true
		end
	end
end

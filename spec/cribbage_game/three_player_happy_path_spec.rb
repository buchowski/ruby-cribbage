module CribbageGame
  RSpec.describe "happy_path_integration" do
    before(:all) do
      @game_over_cb = lambda {}
      @game = Game.new({
        points_to_win: 65,
        game_over_cb: @game_over_cb,
        number_of_players: 3
      })
      @game.cut_for_deal
    end

    context "first hand" do
      before(:all) do
        @dealer_cards = ["8h", "5s", "9c", "3h", "7d"]
        @opponent_cards = ["ah", "7c", "2d", "4c", "6h"]
        @opponent_2_cards = ["2h", "3d", "4d", "5d", "6d"]
        @flip_card = "8s"
        @dealer = @game.dealer
        @opponent = @game.opponent
        @opponent_2 = @game.opponent_2
        @game.deal
        @dealer.hand = @dealer_cards.to_h { |id| [id, true] }
        @opponent.hand = @opponent_cards.to_h { |id| [id, true] }
        @opponent_2.hand = @opponent_2_cards.to_h { |id| [id, true] }
        @game.crib = ["7d"]
      end

      it "should deal to players" do
        expect(@dealer.hand.keys).to eql @dealer_cards
        expect(@opponent.hand.keys).to eql @opponent_cards
        expect(@opponent_2.hand.keys).to eql @opponent_2_cards
      end

      it "should let players discard" do
        @dealer.discard ["7d"]
        @opponent.discard ["6h"]
        @opponent_2.discard ["6d"]

        expect(@dealer.hand.keys.size).to eql 4
        expect(@opponent.hand.keys.size).to eql 4
        expect(@opponent_2.hand.keys.size).to eql 4
        expect(@game.crib.size).to eql 4
      end

      it "should flip_top_card" do
        @game.flip_top_card @flip_card
      end

      it "should play round 1" do
        @opponent.play_card "ah"
        @opponent_2.play_card "2h"
        @dealer.play_card "8h"
        @opponent.play_card "7c" # 18
        @opponent_2.play_card "3d" # 21
        @dealer.play_card "5s"
        @opponent.play_card "2d" # 28
        expect { @opponent_2.play_card "4d" }.to raise_error(NotYourTurnError)
        expect { @dealer.play_card "9c" }.to raise_error(CardTooLargeError)
        expect { @opponent.play_card "4c" }.to raise_error(NotYourTurnError)
        @dealer.play_card "3h" #31
        # TODO 31 score assertion
        # TODO last card score assertions
      end

      it "should play round 2" do
        expect { @dealer.play_card "9c" }.to raise_error(NotYourTurnError)
        expect { @opponent.play_card "qs" }.to raise_error(NotYourCardError)
        @opponent.play_card "4c"
        @opponent_2.play_card "4d"
        # TODO add double 4 score assertions
        @dealer.play_card "9c" #17
        expect { @opponent.play_card "6h" }.to raise_error(NotYourTurnError)
        @opponent_2.play_card "5d" #22
        # TODO last card score assertions
      end

      it "should score opponent's hand" do
        expect { @game.submit_hand_scores @dealer }.to raise_error(NotYourTurnError)
        expect { @game.submit_hand_scores @opponent_2 }.to raise_error(NotYourTurnError)
        @game.submit_hand_scores @opponent
      end

      it "should score opponent_2's hand" do
        @game.submit_hand_scores @opponent_2
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
        @dealer_cards = ["2h", "9d", "7c", "2s", "kd"]
        @opponent_cards = ["10d", "ad", "jh", "5h", "4h"]
        @opponent_2_cards = ["3d", "jd", "ah", "7s", "4d"]
        @flip_card = "qd"
        @dealer = @game.dealer
        @opponent = @game.opponent
        @opponent_2 = @game.opponent_2
        @game.deal
        @dealer.hand = @dealer_cards.to_h { |id| [id, true] }
        @opponent.hand = @opponent_cards.to_h { |id| [id, true] }
        @opponent_2.hand = @opponent_2_cards.to_h { |id| [id, true] }
        @game.crib = ["kd"]
      end

      it "should deal to players" do
        expect(@dealer.hand.keys).to eql @dealer_cards
        expect(@opponent.hand.keys).to eql @opponent_cards
        expect(@opponent_2.hand.keys).to eql @opponent_2_cards
      end

      it "should let players discard" do
        @dealer.discard ["kd"]
        @opponent.discard ["4h"]
        expect { @opponent_2.discard "qs" }.to raise_error(NotYourCardError)
        @opponent_2.discard ["4d"]
      end

      it "should flip_top_card" do
        @game.flip_top_card @flip_card
      end

      it "should play round 1" do
        @opponent.play_card "10d"
        @opponent_2.play_card "3d"
        @dealer.play_card "2h" #15
        # TODO add 15 score assertions
        @opponent.play_card "ad"
        @opponent_2.play_card "jd" #26
        expect { @dealer.play_card "9d" }.to raise_error(CardTooLargeError)
        @dealer.play_card "2s" # 28
        expect { @opponent.play_card "jh" }.to raise_error(NotYourTurnError)
        @opponent_2.play_card "ah" #29
        # TODO last card score assertions
      end

      it "should play round 2" do
        @dealer.play_card "9d"
        @opponent.play_card "jh"  #19
        @opponent_2.play_card "7s" #26
        expect { @dealer.play_card "7c" }.to raise_error(NotYourTurnError)
        @opponent.play_card "5h" #31
        # TODO 31 score assertion
        # TODO last card score assertions
      end

      it "should play round 3" do
        @dealer.play_card "7c"
        # TODO last card score assertions
      end

      it "should scores hands and crib" do
        @game.submit_hand_scores @opponent
        @game.submit_hand_scores @opponent_2
        @game.submit_hand_scores @dealer
        @game.submit_crib_scores
      end
    end

    context "third hand" do
      before(:all) do
        @dealer_cards = ["8c", "10s", "2c", "2h", "6s"]
        @opponent_cards = ["4h", "ks", "8h", "kh", "3c"]
        @opponent_2_cards = ["2d", "3d", "4d", "5d", "6d"]
        @flip_card = "3s"
        @dealer = @game.dealer
        @opponent = @game.opponent
        @opponent_2 = @game.opponent_2
        @game.deal
        @dealer.hand = @dealer_cards.to_h { |id| [id, true] }
        @opponent.hand = @opponent_cards.to_h { |id| [id, true] }
        @opponent_2.hand = @opponent_2_cards.to_h { |id| [id, true] }
        @game.crib = ["6s"]
      end

      it "should deal to players" do
        expect(@dealer.hand.keys).to eql @dealer_cards
        expect(@opponent.hand.keys).to eql @opponent_cards
        expect(@opponent_2.hand.keys).to eql @opponent_2_cards
      end

      it "should let players discard" do
        @dealer.discard ["6s"]
        @opponent.discard ["3c"]
        @opponent_2.discard ["6d"]
      end

      it "should flip_top_card" do
        @game.flip_top_card @flip_card
      end

      it "should play round 1" do
        @opponent.play_card "4h"
        @opponent_2.play_card "2d"
        @dealer.play_card "8c" #14
        @opponent.play_card "ks" # 24
        @opponent_2.play_card "3d" # 27
        expect { @dealer.play_card "10s" }.to raise_error(CardTooLargeError)
        @dealer.play_card "2c" #29
        # opponent doesn't have a playable card since 8h and kh are too large
        expect { @opponent.play_card "8h" }.to raise_error(NotYourTurnError)
        expect { @opponent_2.play_card "4d" }.to raise_error(NotYourTurnError)
        @dealer.play_card "2h" # pair & 31
        # TODO 31 score assertion
        # TODO pair score assertion
        # TODO last card score assertions
      end

      it "should play round 2" do
        @opponent.play_card "8h"
        @opponent_2.play_card "4d"
        @dealer.play_card "10s" #22
        expect { @opponent.play_card "kh" }.to raise_error(NotYourTurnError)
        @opponent_2.play_card "5d" #27
        # TODO 31 score assertion
      end

      it "should play round 3" do
        @opponent.play_card "kh"
        # TODO 31 score assertion
      end

      it "should scores hands and crib" do
        @game.submit_hand_scores @opponent
        @game.submit_hand_scores @opponent_2
        @game.submit_hand_scores @dealer
        @game.submit_crib_scores
      end
    end

    context "fourth hand" do
      before(:all) do
        @dealer_cards = ["8d", "4s", "9d", "6c", "qh"]
        # TODO both opponents have 3d which should be impossible since there's only one 3d in the deck. Fix this in the test setup.
        @opponent_cards = ["ah", "js", "2s", "5h", "3d"]
        @opponent_2_cards = ["2h", "3d", "4d", "5d", "6d"]
        @flip_card = "9c"
        @dealer = @game.dealer
        @opponent = @game.opponent
        @opponent_2 = @game.opponent_2
        @game.deal
        @dealer.hand = @dealer_cards.to_h { |id| [id, true] }
        @opponent.hand = @opponent_cards.to_h { |id| [id, true] }
        @opponent_2.hand = @opponent_2_cards.to_h { |id| [id, true] }
        @game.crib = ["qh"]
      end

      it "should deal to players" do
        expect(@dealer.hand.keys).to eql @dealer_cards
        expect(@opponent.hand.keys).to eql @opponent_cards
        expect(@opponent_2.hand.keys).to eql @opponent_2_cards
      end

      it "should let players discard" do
        @dealer.discard ["qh"]
        @opponent.discard ["3d"]
        @opponent_2.discard ["6d"]
      end

      it "should flip_top_card" do
        @game.flip_top_card @flip_card
      end

      it "should play round 1" do
        @opponent.play_card "ah"
        @opponent_2.play_card "5d"
        @dealer.play_card "8d"
        @opponent.play_card "js" # 24
        @opponent_2.play_card "4d" # 28
        expect { @dealer.play_card "8d" }.to raise_error(NotYourTurnError)
        @opponent.play_card "2s" #30
        # TODO last card score assertion
      end

      it "should play round 2" do
        @opponent_2.play_card "3d"
        @dealer.play_card "4s" # 7
        @opponent.play_card "5h"
        @opponent_2.play_card "2h" #14
        @dealer.play_card "9d" #23
        @dealer.play_card "6c" #29
        # TODO last card score assertion
      end

      it "should scores hands and crib" do
        expect(@game.fsm.game_over?).to eql false
        @game.submit_hand_scores @opponent
        @game.submit_hand_scores @opponent_2

        expect { @game.submit_hand_scores @dealer }.to raise_error(NotYourTurnError)
        expect(@game.fsm.game_over?).to eql true
      end
    end
  end
end

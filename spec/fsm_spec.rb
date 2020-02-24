require './fsm'
require './spec/test_utils'

RSpec.describe FSM, "fsm" do
	before do
		@game = Game.new names: ["brandon", "murphy"]
		@fsm = @game.fsm
	end
	it "should raise error if invalid transition" do
		expect{ @fsm.deal }.to raise_error
	end
	it "should default to waiting_to_start" do
		expect(@fsm.waiting_to_start?).to eql true
	end
	it "start should transition to cutting_for_deal" do
		@fsm.cut_for_deal

		expect(@fsm.cutting_for_deal?).to eql true
	end
	it "deal should call deal cards" do
		@fsm.cut_for_deal

		player1, player2 = @game.players

		expect(player1.hand.empty?).to eql true
		expect(player2.hand.empty?).to eql true

		@fsm.deal

		expect(player1.hand.empty?).to eql false
		expect(player2.hand.empty?).to eql false
	end
	it "cut_for_deal should get the cut card" do
		@fsm.cut_for_deal
		@fsm.deal

		expect(@game.cut_card.nil?).to eql true

		@fsm.flip_top_card

		expect(@game.cut_card.nil?).to eql false
	end
	it "cut_for_deal should transition to playing" do
		@fsm.cut_for_deal
		@fsm.deal

		expect(@fsm.playing?).to eql false

		@fsm.flip_top_card

		expect(@fsm.playing?).to eql true
	end
end

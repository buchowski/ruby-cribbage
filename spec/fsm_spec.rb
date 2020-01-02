require './fsm'
require './spec/test_utils'

RSpec.describe FSM, "fsm" do
	before do
		@game = Game.new names: ["brandon", "murphy"]
		@fsm = FSM.new @game
	end
	it "should return false if invalid transition" do
		expect(@fsm.deal).to eql false
	end
	it "should default to waiting_to_start" do
		expect(@fsm.waiting_to_start?).to eql true
	end
	it "start should transition to cutting_for_deal" do
		@fsm.start

		expect(@fsm.cutting_for_deal?).to eql true
	end
	it "deal should call deal cards" do
		@fsm.start
		@fsm.cut_for_deal

		player1, player2 = @game.players

		expect(player1.hand.empty?).to eql true
		expect(player2.hand.empty?).to eql true

		@fsm.deal

		expect(player1.hand.empty?).to eql false
		expect(player2.hand.empty?).to eql false
	end
	it "cut_for_deal should get the cut card" do
		@fsm.start
		@fsm.cut_for_deal
		@fsm.deal

		expect(@game.cut_card.nil?).to eql true

		@fsm.cut_for_top_card

		expect(@game.cut_card.nil?).to eql false
	end
	it "cut_for_deal should transition to playing" do
		@fsm.start
		@fsm.cut_for_deal
		@fsm.deal

		expect(@fsm.playing?).to eql false

		@fsm.cut_for_top_card

		expect(@fsm.playing?).to eql true
	end
end

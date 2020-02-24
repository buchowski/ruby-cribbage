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
	it "cut_for_deal should transition to cutting_for_deal" do
		@fsm.cut_for_deal

		expect(@fsm.cutting_for_deal?).to eql true
	end
	it "deal should transition to dealing" do
		@fsm.cut_for_deal
		@fsm.deal

		expect(@fsm.dealing?).to eql true
	end
	it "flip_top_card should transition to flipping_top_card" do
		@fsm.cut_for_deal
		@fsm.deal
		@fsm.discard
		@fsm.flip_top_card

		expect(@fsm.flipping_top_card?).to eql true
	end
	it "play should transition to playing" do
		@fsm.cut_for_deal
		@fsm.deal
		@fsm.discard
		@fsm.flip_top_card
		@fsm.play

		expect(@fsm.playing?).to eql true
	end
end

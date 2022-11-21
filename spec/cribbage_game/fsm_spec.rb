RSpec.describe Fsm, "fsm" do
  before(:all) do
    @game = Game.new
    @fsm = @game.fsm
  end
  it "should raise error if invalid transition" do
    expect { @fsm.discard }.to raise_error(AASM::InvalidTransition)
  end
  it "should default to cutting_for_deal" do
    expect(@fsm.cutting_for_deal?).to eql true
  end
  it "deal should transition to dealing" do
    @fsm.deal

    expect(@fsm.dealing?).to eql true
  end
  it "flip_top_card should transition to flipping_top_card" do
    @fsm.discard
    @fsm.flip_top_card

    expect(@fsm.flipping_top_card?).to eql true
  end
  it "play should transition to playing" do
    @fsm.play

    expect(@fsm.playing?).to eql true
  end
end

require './game'
require './player'

RSpec.describe Game, "#deal" do
	playerOne = Player.new "brandon"
	playerTwo = Player.new "murphy"

	context "with two players" do
		it "deals 6 cards to each player" do
			game = Game.new players: [playerOne, playerTwo]

			expect(playerOne.hand.size).to eql 6
			expect(playerTwo.hand.size).to eql 6
		end
	end
end
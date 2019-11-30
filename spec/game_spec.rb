require './game'
require './player'

RSpec.describe Game, "#initialize" do
	context "with zero names" do
		it "should throw an error" do
			expect{Game.new}.to raise_error ArgumentError
		end
	end
	context "with one name" do
		it "should have one player" do
			game = Game.new names: ["brandon"]
			expect(game.players.size).to eql 1
		end
	end
	context "with two names" do
		it "should have two players" do
			game = Game.new names: ["brandon", "murphy"]
			expect(game.players.size).to eql 2
		end
	end
end

RSpec.describe Game, "#deal" do
	context "with two players" do
		it "deals 6 cards to each player" do
			game = Game.new names: ["brandon", "murphy"]
			game.deal

			expect(game.players[0].hand.size).to eql 6
			expect(game.players[1].hand.size).to eql 6
		end
	end
end
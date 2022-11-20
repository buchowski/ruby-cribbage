require 'cribbage_game'
require 'cribbage_game/player'

RSpec.describe Game, "#initialize" do
	context "with two names" do
		it "should have a dealer and opponent" do
			game = Game.new
			expect(game.players.size).to eql 2
			game.cut_for_deal
			dealer = game.dealer
			opponent = game.players.find { |player| player != dealer }

			expect(game.dealer).to eql dealer
			expect(game.opponent).to eql opponent

			game.dealer = opponent

			expect(game.dealer).to eql opponent
			expect(game.opponent).to eql dealer
		end
	end
end

RSpec.describe Game, "#deal" do
	context "with two players" do
		it "deals 6 cards to each player & cuts card" do
			game = Game.new

			expect(game.deck.keys.size).to eql 52
			expect(game.cut_card).to eql nil

			game.cut_for_deal
			game.deal

			expect(game.players[0].hand.keys.size).to eql 6
			expect(game.players[1].hand.keys.size).to eql 6
			expect(game.cut_card).to eql nil
			expect(game.deck.keys.size).to eql 52
		end
	end
end

RSpec.describe Game, "#discard" do
	context "with two players discarding 3 cards" do
		it "should move cards from hands to crib" do
			game = Game.new
			game.cut_for_deal
			game.deal
			playerOne = game.players.first
			playerTwo = game.players[1]

			playerOne.discard playerOne.hand.keys.sample
			playerOne.discard playerOne.hand.keys.sample
			playerTwo.discard playerTwo.hand.keys.sample

			expect(playerOne.hand.keys.count { |card_id| game.deck[card_id] }).to eql 4
			expect(playerTwo.hand.keys.count { |card_id| game.deck[card_id] }).to eql 5
			expect(game.crib.size).to eql 3
		end
	end
end



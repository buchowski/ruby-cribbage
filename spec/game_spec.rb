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
		it "should have a dealer and opponent" do
			game = Game.new names: ["brandon", "murphy"]
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
			game = Game.new names: ["brandon", "murphy"]

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

RSpec.describe Game, "#flip_top_card" do
	it "transitions to playing state" do
		game = Game.new names: ["brandon", "murphy"]
		game.cut_for_deal
		game.deal
		game.flip_top_card
		expect(game.fsm.playing?).to eql true
	end
end

RSpec.describe Game, "#discard" do
	context "with two players discarding 3 cards" do
		it "should move cards from hands to crib" do
			game = Game.new names: ["brandon", "murphy"]
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

RSpec.describe Game, "#play_card" do
	before(:example) do
		@game = Game.new names: ["brandon", "murphy"]
		@game.cut_for_deal
		@game.deal
   		@game.flip_top_card
   	end

	context "with two players discarding 3 cards" do
		it "should move cards from hands to pile" do
			playerOne, playerTwo = @game.players
			@game.whose_turn = playerOne

			playerOne.play_card playerOne.hand.keys.sample
			playerTwo.play_card playerTwo.hand.keys.sample

			expect(playerOne.hand.values.count { |is_still_in_hand| is_still_in_hand }).to eql 5
			expect(playerTwo.hand.values.count { |is_still_in_hand| is_still_in_hand }).to eql 5
			expect(@game.pile.size).to eql 2
		end
	end

	# context "increment pile_score" do
	# 	it "should if card can be added" do
	# 		ace, five, ten, five_two, ten_two, ten_three = get_card_ids_by_num ["Ace", 5, 10, 5, 10, 10]
	# 		dealer, opponent = @game.dealer, @game.opponent
	# 		opponent.hand = [five, ten, ace, ten_three].to_h { |card_id| [card_id, true] }
	# 		dealer.hand = [ten_two, five_two].to_h { |card_id| [card_id, true] }

	# 		@game.play_card opponent, ten
	# 		expect(@game.pile_score).to eql 10
	# 		expect(opponent.score).to eql 0
	# 		expect(@game.pile.size).to eql 1

	# 		@game.play_card dealer, five_two
	# 		expect(@game.pile_score).to eql 15
	# 		expect(dealer.score).to eql 2
	# 		expect(@game.pile.size).to eql 2

	# 		@game.play_card opponent, five
	# 		expect(@game.pile_score).to eql 20
	# 		expect(opponent.score).to eql 2
	# 		expect(@game.pile.size).to eql 3

	# 		@game.play_card dealer, ten_two
	# 		expect(@game.pile_score).to eql 30
	# 		expect(dealer.score).to eql 2
	# 		expect(@game.pile.size).to eql 4

	# 		expect { @game.play_card dealer, ten_three }.to raise_error(NotYourTurnError)
	# 		expect(@game.pile_score).to eql 30
	# 		expect(dealer.score).to eql 2
	# 		expect(@game.pile.size).to eql 4

	# 		 @game.play_card opponent, ace
	# 		expect(@game.pile_score).to eql 0 
	# 		expect(opponent.score).to eql 4
	# 		expect(@game.pile.size).to eql 0
	# 	end
	# end
end



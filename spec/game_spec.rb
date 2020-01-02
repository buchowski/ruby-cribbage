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
			dealer, opponent = game.players

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

			expect(game.deck.cards.size).to eql 52
			expect(game.cut_card).to eql nil

			game.deal

			expect(game.players[0].hand.size).to eql 6
			expect(game.players[1].hand.size).to eql 6
			expect(game.cut_card).to eql nil
			expect(game.deck.cards.size).to eql 40
		end
	end
end

RSpec.describe Game, "#cut_for_top_card" do
	it "gives 2 points to dealer if cut_card is Jack" do
		game = Game.new names: ["brandon", "murphy"]
		jack_card = get_cards(["Jack"]).first
		game.deck.cards = Array.new(13, jack_card)
		game.cut_for_top_card
		expect(game.dealer.score).to eql 2
	end
end

RSpec.describe Game, "#add_card_to_crib" do
	context "with two players discarding 3 cards" do
		it "should move cards from hands to crib" do
			game = Game.new names: ["brandon", "murphy"]
			game.deal
			playerOne = game.players.first
			playerTwo = game.players[1]

			playerOne.add_card_to_crib playerOne.hand.sample
			playerOne.add_card_to_crib playerOne.hand.sample
			playerTwo.add_card_to_crib playerTwo.hand.sample

			expect(playerOne.hand.size).to eql 4
			expect(playerTwo.hand.size).to eql 5
			expect(game.crib.size).to eql 3
		end
	end
end

RSpec.describe Game, "#play_card" do
	context "with two players discarding 3 cards" do
		it "should move cards from hands to pile" do
			game = Game.new names: ["brandon", "murphy"]
			game.deal
			playerOne, playerTwo = game.players

			playerOne.add_card_to_pile playerOne.hand.sample
			playerTwo.add_card_to_pile playerTwo.hand.sample

			expect(playerOne.hand.size).to eql 5
			expect(playerTwo.hand.size).to eql 5
			expect(game.pile.size).to eql 2
		end
	end

	context "when cards are added to pile" do
		it "should increment pile_score if card can be added" do
			game = Game.new names: ["brandon", "murphy"]
			ace, five, ten, five_two, ten_two, ten_three = get_cards ["Ace", 5, 10, 5, 10, 10]
			dealer, opponent = game.whose_turn, game.not_whose_turn
			dealer.hand = [five, ten, ace, ten_three]
			opponent.hand = [ten_two, five_two]

			is_success = game.play_card dealer, ten
			expect(game.pile_score).to eql 10
			expect(dealer.score).to eql 0
			expect(is_success).to eql true
			expect(game.pile.size).to eql 1

			is_success = game.play_card opponent, five_two
			expect(game.pile_score).to eql 15
			expect(opponent.score).to eql 2
			expect(is_success).to eql true
			expect(game.pile.size).to eql 2

			is_success = game.play_card dealer, five
			expect(game.pile_score).to eql 20
			expect(dealer.score).to eql 2
			expect(is_success).to eql true
			expect(game.pile.size).to eql 3

			is_success = game.play_card opponent, ten_two
			expect(game.pile_score).to eql 30
			expect(opponent.score).to eql 2
			expect(is_success).to eql true
			expect(game.pile.size).to eql 4

			expect { game.play_card dealer, ten_three }.to raise_error
			expect(game.pile_score).to eql 30
			expect(dealer.score).to eql 2
			expect(game.pile.size).to eql 4

			is_success = game.play_card dealer, ace
			expect(game.pile_score).to eql 0 
			expect(dealer.score).to eql 4
			expect(is_success).to eql true
			expect(game.pile.size).to eql 0
		end
	end
end



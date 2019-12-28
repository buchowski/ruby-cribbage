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

RSpec.describe Game, "#add_card_to_pile" do
	context "with two players discarding 3 cards" do
		it "should move cards from hands to pile" do
			game = Game.new names: ["brandon", "murphy"]
			game.deal
			playerOne = game.players.first
			playerTwo = game.players[1]

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
			ace, five, ten = get_cards ["Ace", 5, 10]

			is_success, points = game.add_card_to_pile ten
			expect(game.pile_score).to eql 10
			expect(points).to eql 0
			expect(is_success).to eql true
			expect(game.pile.size).to eql 1

			is_success, points = game.add_card_to_pile five
			expect(game.pile_score).to eql 15
			expect(points).to eql 2
			expect(is_success).to eql true
			expect(game.pile.size).to eql 2

			is_success, points = game.add_card_to_pile five
			expect(game.pile_score).to eql 20
			expect(points).to eql 0
			expect(is_success).to eql true
			expect(game.pile.size).to eql 3

			is_success, points = game.add_card_to_pile ten
			expect(game.pile_score).to eql 30
			expect(points).to eql 0
			expect(is_success).to eql true
			expect(game.pile.size).to eql 4

			is_success, points = game.add_card_to_pile ten
			expect(game.pile_score).to eql 30
			expect(points).to eql 0
			expect(is_success).to eql false
			expect(game.pile.size).to eql 4

			is_success, points = game.add_card_to_pile ace
			expect(game.pile_score).to eql 31
			expect(points).to eql 2
			expect(is_success).to eql true
			expect(game.pile.size).to eql 5
		end
	end
end



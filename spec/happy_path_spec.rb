require './game'

RSpec.describe Score, "score_client" do
	game = Game.new names: ["brandon", "murphy"]
	deck_hash = get_cards_hash game.deck.cards

	dealer_cards = ["8h", "5s", "9c", "3h", "7d", "qc"]
	opponent_cards = ["ah", "7c", "2d", "4c", "6h", "9s"]
	player_card_ids = dealer_cards + opponent_cards

	it "should take two players" do
		expect(game.players.size).to eql 2
	end

	it "should determine dealer via cut_for_deal" do
		expect(game.dealer).to eql nil
		game.cut_for_deal
		expect(game.dealer).to be_an_instance_of(Player)
		expect(game.opponent).to be_an_instance_of(Player)
	end

	it "should deal to players" do
		game.deal { |cards| frontload_deck_with(cards, player_card_ids) }

		expect(hand_ids_of game.dealer).to eql dealer_cards
		expect(hand_ids_of game.opponent).to eql opponent_cards
	end

	it "should allow players to discard" do
		nine, three, two, four = get_cards deck_hash, ['9c', '3h', '2d', '4c']
		game.dealer.discard [nine, three]
		game.opponent.discard [two, four]

		expect(game.dealer.hand.size).to eql 4
		expect(game.opponent.hand.size).to eql 4
		expect(game.crib.size).to eql 4
	end
end

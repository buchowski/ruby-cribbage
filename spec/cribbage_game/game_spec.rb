RSpec.describe CribbageGame::Game, "#initialize" do
  context "with two names" do
    it "should have a dealer and opponent" do
      game = CribbageGame::Game.new
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

RSpec.describe CribbageGame::Game, "#deal" do
  context "with two players" do
    it "deals 6 cards to each player & cuts card" do
      game = CribbageGame::Game.new

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

  context "with three players" do
    it "deals 5 cards to each player and one card to the crib" do
      game = CribbageGame::Game.new(number_of_players: 3)

      game.cut_for_deal
      game.deal

      expect(game.players.map { |player| player.hand.keys.size }).to eql [5, 5, 5]
      expect(game.crib.size).to eql 1
      expect(game.deck.keys.size).to eql 52
    end
  end
end

RSpec.describe CribbageGame::Game, "#undealt_card_ids" do
  it "excludes crib cards and the cut card from undealt cards" do
    game = CribbageGame::Game.new
    game.cut_for_deal
    game.deal

    # Simulate discards to crib, leaving a crib of exactly 3 cards in a two-player game
    player_one = game.players.first
    player_two = game.players[1]

    player_one.discard(player_one.hand.keys.first)
    player_one.discard(player_one.hand.keys.first)
    player_two.discard(player_two.hand.keys.first)
    player_two.discard(player_two.hand.keys.first)

    game.flip_top_card

    undealt_ids = game.undealt_card_ids

    expect(undealt_ids & game.crib).to be_empty
    expect(undealt_ids).not_to include(game.cut_card)
  end
end

RSpec.describe CribbageGame::Game, "#discard" do
  context "with two players discarding 3 cards" do
    it "should move cards from hands to crib" do
      game = CribbageGame::Game.new
      game.cut_for_deal
      game.deal
      player_one = game.players.first
      player_two = game.players[1]

      player_one.discard player_one.hand.keys.sample
      player_one.discard player_one.hand.keys.sample
      player_two.discard player_two.hand.keys.sample

      expect(player_one.hand.keys.count { |card_id| game.deck[card_id] }).to eql 4
      expect(player_two.hand.keys.count { |card_id| game.deck[card_id] }).to eql 5
      expect(game.crib.size).to eql 3
    end
  end
end

RSpec.describe CribbageGame::Game, "#next_player" do
  context "with two players" do
    it "cycles to the next player and wraps around" do
      game = CribbageGame::Game.new
      player_0 = game.players[0]
      player_1 = game.players[1]

      expect(game.next_player(player_0)).to eql player_1
      expect(game.next_player(player_1)).to eql player_0
    end
  end

  context "with three players" do
    it "cycles through all players in sequence" do
      game = CribbageGame::Game.new(number_of_players: 3)
      player_0 = game.players[0]
      player_1 = game.players[1]
      player_2 = game.players[2]

      expect(game.next_player(player_0)).to eql player_1
      expect(game.next_player(player_1)).to eql player_2
      expect(game.next_player(player_2)).to eql player_0
    end
  end
end

RSpec.describe CribbageGame::Game, "#dealer_rotation" do
  context "with three players" do
    it "rotates the dealer after each round" do
      game = CribbageGame::Game.new(number_of_players: 3)
      game.cut_for_deal

      dealer_1 = game.dealer
      dealer_2 = game.next_player(dealer_1)
      dealer_3 = game.next_player(dealer_2)

      # Verify rotation matches player sequence
      expect(game.next_player(dealer_1)).to eql dealer_2
      expect(game.next_player(dealer_2)).to eql dealer_3
      expect(game.next_player(dealer_3)).to eql dealer_1
    end
  end
end

RSpec.describe CribbageGame::Game, "#turn_order" do
  context "with three players" do
    it "starts with the first non-dealer after cut_for_deal" do
      game = CribbageGame::Game.new(number_of_players: 3)
      game.cut_for_deal

      expect(game.whose_turn).to eql game.opponent
    end

    it "starts with the first non-dealer after flip_top_card" do
      game = CribbageGame::Game.new(number_of_players: 3)
      game.cut_for_deal
      game.deal

      # Each player discards 1 card (5 - 1 = 4 left)
      game.players.each do |player|
        player.discard(player.hand.keys.first)
      end

      game.flip_top_card

      expect(game.whose_turn).to eql game.opponent
    end
  end
end

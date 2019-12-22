require './game'
require './player'

RSpec.describe Player, "#add_card_to_pile" do
	it "should update players score" do
		game = Game.new names: ["brandon", "murphy"]
		player = game.players.first
		ace, five, ten = nil, nil, nil

		game.deck.cards.each do |card|
			ace = card if card.value == 1
			five = card if card.value == 5
			ten = card if card.value == 10
		end

		player.add_card_to_pile five
		expect(player.score).to eql 0


		player.add_card_to_pile ten
		expect(player.score).to eql 2


		player.add_card_to_pile ten
		expect(player.score).to eql 2

		player.add_card_to_pile five
		expect(player.score).to eql 2


		player.add_card_to_pile ace
		expect(player.score).to eql 4
	end
end

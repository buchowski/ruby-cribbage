require './game'
require './spec/test_utils'

RSpec.describe Player, "" do
	context "#add_card_to_pile" do			
		it "should update players score" do
			game = Game.new names: ["brandon", "murphy"]
			player = game.players.first
			ace, five, ten = get_cards ["Ace", 5, 10]

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

	context "#score_hand" do
		it "" do

		end
	end
end

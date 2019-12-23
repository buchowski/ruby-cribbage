require './game'
require './spec/test_utils'

RSpec.describe Player, "" do
	before(:example) do
		@game = Game.new names: ["brandon", "murphy"]
		@player = @game.players.first
	end

	context "#add_card_to_pile" do			
		it "should update players score" do
			ace, five, ten = get_cards ["Ace", 5, 10]

			@player.add_card_to_pile five
			expect(@player.score).to eql 0

			@player.add_card_to_pile ten
			expect(@player.score).to eql 2

			@player.add_card_to_pile ten
			expect(@player.score).to eql 2

			@player.add_card_to_pile five
			expect(@player.score).to eql 2

			@player.add_card_to_pile ace
			expect(@player.score).to eql 4
		end
	end

	context "#score_hand" do
		it "should score a pair and 15" do
			cards = get_cards ["Ace", "Ace", 5, 10, 7]
			@game.cut_card = cards.slice! 0
			@player.hand = cards
			score = @player.score_hand
			expect(score).to eql 4
		end

		# it "should score a 5-card run and 15" do
		# 	cards = get_cards [6, 3, 4, 5, "Jack"]
		# 	@game.cut_card = cards.slice! 0
		# 	@player.hand = cards
		# 	score = @player.score_hand
		# 	expect(score).to eql 6
		# end

		it "should score 3-of-a-kind & multiple 15s" do
			cards = get_cards ["King", "Queen", 5, 5, 5]
			@game.cut_card = cards.slice! 0
			@player.hand = cards
			score = @player.score_hand
			expect(score).to eql 20
		end
	end
end

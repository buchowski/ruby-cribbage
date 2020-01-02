require './game'
require './spec/test_utils'

RSpec.describe Player, "" do
	before(:example) do
		@game = Game.new names: ["brandon", "murphy"]
		@player = @game.players.first
	end

	context "#add_card_to_pile" do			
		it "should transition between players and update player scores" do
			ace, five, ten, five_two, ten_two = get_cards ["Ace", 5, 10, 5, 10]
			dealer, opponent = @game.whose_turn, @game.not_whose_turn
			dealer.hand = [five, ten, ace]
			opponent.hand = [ten_two, five_two]

			dealer.add_card_to_pile five
			expect(dealer.score).to eql 0

			opponent.add_card_to_pile ten_two
			expect(opponent.score).to eql 2

			dealer.add_card_to_pile ten
			expect(dealer.score).to eql 2

			opponent.add_card_to_pile five_two
			expect(opponent.score).to eql 2

			dealer.add_card_to_pile ace
			expect(dealer.score).to eql 4
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

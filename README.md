# ruby-cribbage
Two player cribbage game written in Ruby. https://bicyclecards.com/how-to-play/cribbage/
 
## Installation
`$ git clone https://github.com/buchowski/ruby-cribbage.git`
## Usage
```ruby
game = Game.new
game.cut_for_deal # randomly determines dealer
game.deal # deals 6 cards to game.dealer.hand & game.opponent.hand
game.dealer.discard ["7d", "qc"] # takes cards from hand and puts in crib
game.opponent.discard ["6h", "9s"]
game.flip_top_card # two for his heels if Jack
game.opponent.play_card 'ah' # game.opponent.total_score is updated automatically
game.dealer.play_card '8h'
... # continue until all cards are played
game.submit_hand_scores(game.opponent) # adds the hand's score to game.opponent.total_score
game.submit_hand_scores(game.dealer)
game.submit_crib_scores  # adds the crib's score to game.dealer.total_score
game.deal # begin next round
```
### Optional initialization options
```ruby
game = Game.new ({
  points_to_win: 35, # overrides default of 121
  game_over_cb: proc { puts "game over" } # function called on game_over
})
```
### Tests
`$ rspec`

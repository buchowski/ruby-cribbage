# CribbageGame

Two player cribbage game. https://bicyclecards.com/how-to-play/cribbage/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cribbage_game'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cribbage_game

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
### Initialization options
```ruby
game = Game.new ({
  points_to_win: 35, # overrides default of 121
  game_over_cb: proc { puts "game over" } # function called on game_over
})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/buchowski/ruby-cribbage.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

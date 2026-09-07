# CribbageGame

Ruby [cribbage](https://bicyclecards.com/how-to-play/cribbage/) game engine. Includes a `play_with_ai` game runner for play against AI players using OpenAI models (default: gpt-5-nano)

## Installation

```sh
gem install cribbage_game
```

## Usage

```ruby
game = CribbageGame::Game.new({ number_of_players: 2 })
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

## Development

```sh
bundle install
bundle exec rake spec # tests
bundle exec rake standard # linting
./bin/console # shell script to start an interactive console
```

### Play against AI

## Dependencies
```sh
bundle install
gem install ruby-openai
export OPENAI_API_KEY=your-api-key
```

## Playing the game
```sh
bin/play_with_ai --help # print command line options
bin/play_with_ai --players 3 --name Kevin --points-to-win 32 # initialize game
rdbg -O --port 12345 bin/play_with_ai # run with debugger
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/buchowski/ruby-cribbage.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

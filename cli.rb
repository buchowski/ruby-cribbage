require './player'
require './game'

names = ARGV
players = names.map { |name| Player.new name }
game = Game.new :players => players



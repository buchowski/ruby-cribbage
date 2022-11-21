module CribbageGame
  class Player
    attr_accessor :id, :hand, :total_score

    def initialize game, id
      @id = id
      @game = game
      @hand = []
      @total_score = 0
    end

    def discard cards
      [cards].flatten.each do |card|
        @game.discard self, card
      end
    end

    def play_card card
      @game.play_card self, card
    end

    def score_hand
      @game.score_hand self
    end
  end
end

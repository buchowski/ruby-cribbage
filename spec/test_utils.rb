require './card'

def get_cards card_request
	@deck = CardDeck::Deck.new
	cards = []
	@deck.cards.each do |card|
		index = card_request.index(card.num)

		if !index.nil?
			card_request[index] = nil
			cards << card
		end

		return cards if card_request.size == cards.size
	end
end
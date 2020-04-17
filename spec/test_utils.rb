require './card'

def get_cards cards, card_request
	matches = []
	cards.each do |card|
		index = card_request.index(card.num)

		if !index.nil?
			card_request[index] = nil
			matches << card
		end

		return matches if card_request.size == matches.size
	end

	if !card_request.compact.empty?
		raise "You requested non-existent card #{card_request.compact}"
	end
end

def get_cards_from_fresh_deck card_request
	deck = CardDeck::Deck.new
	return get_cards deck.cards, card_request
end

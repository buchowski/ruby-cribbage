require './card'

def get_cards cards, card_request
	raise "get_cards expects a hash of cards" if !cards.is_a? Hash

	return card_request.map do |card|
		raise "Invalid card request #{card}" if cards[card.id].nil?
		cards[card.id]
	end
end

def get_cards_hash cards
	cards.inject({}) do |card_map, card| 
		card_map[card.id] = card
		card_map
	end
end

def get_card_num_hash cards
	cards.inject({}) do |card_num_map, card|
		card_num_map[card.num] = card_num_map[card.num] || []
		card_num_map[card.num] << card
		card_num_map
	end
end

def get_cards_by_num card_by_num_request
	card_num_hash = get_card_num_hash(CardDeck::Deck.new.cards)
	card_by_num_request.map do |num|
		raise "Invalid card request #{num}" if card_num_hash[num].nil?
		card_num_hash[num].pop
	end
end

def get_cards_from_new_deck card_request
	deck_cards_hash = get_cards_hash(CardDeck::Deck.new.cards)

	return get_cards deck_cards_hash, card_request
end


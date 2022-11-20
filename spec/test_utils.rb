require 'card'
require 'game'

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

def get_card_ids_by_num card_by_num_request
	get_cards_by_num(card_by_num_request).map { |card| card.id }
end

def generate_n_random_card_ids n 
	deck_cards_hash = Game.get_cards_hash(CardDeck::Deck.new.cards)

	deck_cards_hash.keys.shuffle.slice(0, n)
end

n = 12
n_random_card_ids = generate_n_random_card_ids(n + 1)
puts "***"
puts "some suggested test cards:"
print "@dealer_cards = ", n_random_card_ids.slice!(0, n/2), "\n"
print "@opponent_cards = ", n_random_card_ids.slice!(0, n/2), "\n"
print "@flip_card = ", "\"#{n_random_card_ids.pop}\"", "\n"
puts "***"

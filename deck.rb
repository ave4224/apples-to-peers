load('card.rb')
require 'securerandom'

class Deck
	def initialize()
		@black_cards = []
		@white_cards = []
	end

	def load_from_file(fpath)
		File.open(fpath, 'r') do |deck_file|
			deck_file.each_line do |line|
				if !line.strip.start_with?('#') and !(line =~ /^\s*$/)
					if line.strip == 'black_cards' then
						@current_type = :black
						next
					end
					if line.strip == 'white_cards' then
						@current_type = :white
						next
					end
					if @current_type.nil?
						raise 'Card type not specified before card text'
					end
					if @current_type == :black
						@black_cards << BlackCard.new(line.strip)
					end
					if @current_type == :white
						@white_cards << WhiteCard.new(line.strip)
					end
				end
			end
		end
	end

	def serialize()
		data = 'black_cards|'
		@black_cards.each do |card|
			data += "#{card.text}|"
		end
		data += 'white_cards|'
		@white_cards.each do |card|
			data += "#{card.text}|"
		end
		return data
	end

	def load_from_serialized(serialized)
		serialized.split('|').each do |line|
			if !line.strip.start_with?('#') and !(line =~ /^\s*$/)
				if line.strip == 'black_cards' then
					@current_type = :black
					next
				end
				if line.strip == 'white_cards' then
					@current_type = :white
					next
				end
				if @current_type.nil?
					raise 'Invalid serialized data'
				end
				if @current_type == :black
					@black_cards << BlackCard.new(line.strip)
				end
				if @current_type == :white
					@white_cards << WhiteCard.new(line.strip)
				end
			end
		end
	end

	def get_hash()
		Digest::SHA256.hexdigest(serialize())
	end

	def black_cards()
		@black_cards
	end

	def white_cards()
		@white_cards
	end

	def shuffle(groupRandomSeed)
		whiteCardsPRNG=prng_from_string(groupRandomSeed+"whiteCards")
		@white_cards=@white_cards.shuffle(random: whiteCardsPRNG)
		puts "White Shuffled: #{@white_cards}"
		blackCardsPRNG=prng_from_string(groupRandomSeed+"blackCards")
		@black_cards=@black_cards.shuffle(random: blackCardsPRNG)
		puts "Black Shuffled: #{@black_cards}"
	end
	def white_segments(num_groups)
  		return [] if num_groups == 0
  		slice_size = (@white_cards.size/Float(num_groups)).ceil
  		@white_cards.each_slice(slice_size).to_a
	end
	def white_segment(numPlayers,index)
		return white_segments(numPlayers)[index]
	end
end
def prng_from_string(seed_str)
	Random.new((Digest::SHA1.hexdigest(seed_str).to_i(16)).to_f)
end

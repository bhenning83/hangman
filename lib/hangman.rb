# When game is initalized, select a random word from 5desk
# Check to make sure word is bigger than 4 letters and less than 12
# create an array populated with a number of dashes equal to the length of the word
# allow user to guess a letter
# create array to keep track of letters guessed
# if the word includes the letter, replace the dash at that letter's index
#   -if no more dashes in array are found, game ends, display winner message
# if the letter is not found in the word, deduct from the lives remaining tally
#  -if lives remaining reaches zero, game ends, display loser message

# Each round:
#   get guess from user
#   check if it's valid (just one a-z letter)
#   add letter to letters_guessed array
#   search through word to see if the letter is included
#   either deduct from lives remaining or replace the dash in word display
#   check for a winner
require 'pry'
require 'json'
module Playable
  def select_random_word
    dictionary = File.read('5desk.txt').split
    valid_words = dictionary.select { |word| word.length > 3 && word.length < 13 }

    # removes proper nouns (first letter must be lowercase)
    valid_words = valid_words.select { |word| /[[:lower:]]/.match(word[0]) }
    valid_words.sample
  end

  def check_for_matches(array, word)
    current_board = Array.new(word.length, '_')
    word.split('').each_with_index do |letter, i|
      current_board[i] = letter if array.include?(letter)
    end
    puts "\n\n#{current_board.join(' ')}"
  end

  def winner(letters_guessed, secret_word)
    letters = secret_word.split('')
    matches = letters.count { |letter| letters_guessed.include?(letter) }
    if matches == secret_word.length
      puts 'You win!'
        exit
    end
  end
end

module Savable
  def to_json
    JSON.dump ({
      :secret_word => secret_word,
      :letters_guessed => letters_guessed,
      :lives_left => lives_left
    })
  end

  def save
    puts 'Enter a name for your saved game.'
    save_name = gets.chomp
    stream = to_json
    saved_game = File.open(@path + save_name, 'w') { |f| f.puts stream}
    puts "Game saved. Do you want to quit your game? yes/no"
    exit if gets.chomp.downcase == 'yes'
  end
  
  def load
    puts "What is the name of your saved game?"
    answer = gets.chomp
    save = File.read(@path + answer)
    data = JSON.parse(save)
    @secret_word = data['secret_word']
    @letters_guessed = data['letters_guessed']
    @lives_left = data['lives_left']
    check_for_matches(letters_guessed, secret_word)
  end

  def ask_to_load
    puts "Do you want to start a new game or continue a saved game? new/continue"
    return nil unless gets.chomp.strip.downcase == 'continue'
    load
  end

end

class Game
  include Playable
  include Savable

  attr_accessor :secret_word, :letters_guessed, :lives_left

  def initialize
    @secret_word = select_random_word
    @letters_guessed = []
    @lives_left = 6
    @path = '/Users/brendonhenning/the_odin_project/ruby/hangman/saves/'
    @guess = ''
  end

  def get_guess
    # ensures guess is one letter a-z or prompting to save
    until @guess.match?(/\A[a-zA-Z]{1}\z/) || @guess.match?('save')
      puts 'Guess a letter or type \'save\' to save game.'
      @guess = gets.chomp.strip.downcase
    end
    if @guess == 'save'
      @guess = ''
      save
    end
    get_guess if already_guessed?(@guess)
    letters_guessed.push(@guess)
  end

  def already_guessed?(guess)
    guess = ''
    letters_guessed.include?(guess)
  end

  def match?(letter)
    @lives_left -= 1 unless secret_word.include?(letter)
  end

  def play_turn
    puts "\n\n#{@lives_left} lives remaining"
    puts "already guessed: #{letters_guessed.join(' ')}"
    @guess = ''
    get_guess
    match?(@guess)
    check_for_matches(letters_guessed, secret_word)
    winner(letters_guessed, secret_word)
  end

  def play_game
    ask_to_load
    if letters_guessed.length == 0
      puts Array.new(secret_word.length, '_').join(' ') # displays empty tiles for new game
    end
    while @lives_left.positive?
      play_turn
    end
    puts "You lose! The word was #{secret_word}"
  end


  
end

game = Game.new
game.play_game

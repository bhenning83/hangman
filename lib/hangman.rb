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

  def winner?(letters_guessed, secret_word)
    letters = secret_word.split('')
    matches = letters.count { |letter| letters_guessed.include?(letter) }
    matches == secret_word.length
  end
end

class Game
  include Playable

  attr_accessor :secret_word, :letters_guessed, :lives_left

  def initialize
    @secret_word = select_random_word
    @letters_guessed = []
    @lives_left = 6
  end

  def get_guess
    guess = ''
    # ensures guess is one letter a-z
    until guess.match?(/\A[a-zA-Z]{1}\z/)
      puts 'Guess a letter'
      guess = gets.chomp.downcase
    end
    if already_guessed?(guess)
      guess = ''
      get_guess
    end
    letters_guessed.push(guess)
    match?(guess)
  end

  def already_guessed?(guess)
    letters_guessed.include?(guess)
  end

  def match?(guess)
    @lives_left -= 1 unless secret_word.include?(guess)
  end

  def play_game
    puts Array.new(secret_word.length, '_').join(' ') # displays empty tiles
    while @lives_left.positive?
      puts "\n\n#{@lives_left} lives remaining"
      puts "already guessed: #{letters_guessed.join(' ')}"
      get_guess
      check_for_matches(letters_guessed, secret_word)
      if winner?(letters_guessed, secret_word)
        puts 'You win!'
        exit
      end
    end
    puts "You lose! The word was #{secret_word}"
  end
end

game = Game.new
game.play_game

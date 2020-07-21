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
require "pry"
module Playable
  def select_random_word
    dictionary = File.read('5desk.txt').split
    valid_words = dictionary.select {|word| word.length > 3 && word.length < 13}
  
      #removes proper nouns (first letter must be lowercase)
    valid_words = valid_words.select {|word| /[[:lower:]]/.match(word[0])}
    valid_words.sample
  end

  def check_for_matches(array, word)
    current_board = Array.new(word.length, '_')
    word.split('').each_with_index do |letter, i|
      current_board[i] = letter if array.include?(letter)
    end
    puts current_board.join(' ')
  end

  def winner?(letters_guessed, secret_word)
    letters = secret_word.split('')
    matches = letters.count {|letter| letters_guessed.include?(letter)}
    matches == secret_word.length
  end
end

class Game
  include Playable
  
  attr_accessor :secret_word, :letters_guessed
  
  def initialize
    @secret_word = select_random_word
    @letters_guessed = []
  end

  def get_guess
    puts "Guess a letter"
    guess = gets.chomp.downcase 

    #ensures guess is one letter a-z
    if !guess.match? /\A[a-zA-Z]{1}\z/ then get_guess end
    letters_guessed.push(guess)
  end
  
  def play_game
    12.times do 
      get_guess
      check_for_matches(letters_guessed, secret_word)
      break if winner?(letters_guessed, secret_word)
    end
  end
end

game = Game.new
p game.secret_word
game.play_game
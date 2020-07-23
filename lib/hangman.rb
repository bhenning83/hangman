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
    return unless matches == secret_word.length
    puts 'You win!'
    exit
  end
end

module Savable
  def to_json(*_args)
    JSON.dump({
                secret_word: secret_word,
                letters_guessed: letters_guessed,
                lives_left: lives_left
              })
  end

  def save
    puts 'Enter a name for your saved game.'
    save_name = gets.chomp
    stream = to_json
    File.open(@path + save_name, 'w') { |f| f.puts stream }
    puts 'Game saved. Do you want to quit your game? yes/no'
    exit if gets.chomp.downcase == 'yes'
  end

  def load
    puts 'What is the name of your saved game?'
    answer = gets.chomp
    save = File.read(@path + answer)
    data = JSON.parse(save)
    @secret_word = data['secret_word']
    @letters_guessed = data['letters_guessed']
    @lives_left = data['lives_left']
    check_for_matches(letters_guessed, secret_word)
  end

  def ask_to_load
    puts 'Do you want to start a new game or continue a saved game? new/continue'
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

  def select_letter
    # ensures guess is one letter a-z or prompting to save
    until @guess.match?(/\A[a-zA-Z]{1}\z/) || @guess.match?('save')
      puts 'Guess a letter or type \'save\' to save game.'
      @guess = gets.chomp.strip.downcase
    end
    if @guess == 'save'
      @guess = ''
      save
    elsif already_guessed?
      @guess = ''
      select_letter
    else
      letters_guessed.push(@guess)
    end
  end

  def already_guessed?
    letters_guessed.include?(@guess)
  end

  def match?(letter)
    @lives_left -= 1 unless secret_word.include?(letter)
  end

  def play_turn
    puts "\n\n#{@lives_left} lives remaining"
    puts "already guessed: #{letters_guessed.join(' ')}"
    @guess = ''
    select_letter
    match?(@guess)
    check_for_matches(letters_guessed, secret_word)
    winner(letters_guessed, secret_word)
  end

  def play_game
    ask_to_load
    if letters_guessed.empty?
      puts Array.new(secret_word.length, '_').join(' ') # displays empty tiles for new game
    end
    play_turn while @lives_left.positive?
    puts "You lose! The word was #{secret_word}"
  end
end

game = Game.new
game.play_game

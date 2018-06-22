require 'yaml'
require 'pry'

class HangMan
  def initialize
    @right_guess = []
    @wrong_guess = []
    @guess_count = 6
    @guess_remaining = 6
    @guessed_word = ''
    @saved_game = false
    @word = ''
  end

  def menu
    puts '1: Play'
    puts '2: Load saved game'
    puts '3: Exit'
    puts '-' * 15
    input = gets.chomp.strip
    case input
    when '1' then
      @guess_remaining = 6
      @saved_game = false
      start
    when '2' then
      load_saved_game
    when '3' then
      exit_game
    else
      puts 'Invalid input'
      menu
    end
  end

  def start
    random_words
    get_random_word(random_words).chomp
    play
  end

  def play
    guess_word
  end

  def random_words
    random_words = []
    lines = File.readlines('5desk.txt')
    lines.each do |line|
      random_words << line if (line.length >= 5) && (line.length <= 12)
    end
    random_words
  end

  def get_random_word(words)
    word = words[rand(words.length)].downcase
    w = '_' * word.length
    puts "Word: #{w.split('').join(' ')}"
    word = word.chomp.strip
    @word = word
  end

  def save_game
    puts 'Enter name to save your game as: '
    filename = gets.chomp

    path = Dir.mkdir '../saved_games' unless Dir.exist? '../saved_games'
    path = "../saved_games/#{filename}.yml"
    File.open(path, 'w') do |file|
      file.puts YAML.dump(
        right_guess: @right_guess,
        wrong_guess: @wrong_guess,
        guess_count: @guess_count,
        guess_remaining: @guess_remaining,
        guessed_word: @guessed_word,
        saved_game: true,
        word: @word
      )
    end
    puts 'Game saved! '
    exit_game
  end

  def load_saved_game
    puts 'Select a saved game'

    saved_games = Dir.entries('../saved_games').reject { |dir| dir == '.' || dir == '..' }

    puts saved_games

    filename = gets.chomp.strip

    path = "../saved_games/#{filename}"

    file = File.open(path, 'r')

    saved_game = YAML.load_file(file)

    @right_guess = saved_game[:right_guess]
    @wrong_guess = saved_game[:wrong_guess]
    @guess_count = saved_game[:guess_count]
    @guessed_word = saved_game[:guessed_word]
    @guess_remaining = saved_game[:guess_remaining]
    @saved_game = saved_game[:saved_game]
    @word = saved_game[:word]

    saved_game_details
    play

  end

  def exit_game
    abort('Exiting\n=== HANGMAN v1.0 ===')
  end

  def miss(input)
    @wrong_guess << input
    @guess_remaining -= 1
    puts "Wrong Guess!! You have #{@guess_count - @wrong_guess.length} trials remaining."
  end

  def correct(input)
    @right_guess << input
    puts 'Correct Guess!!'
  end

  def won(word)
    puts 'YOU WON'
    puts "Word: #{word}"
    puts '-' * 15
    menu
  end

  def summary
    puts '-' * 15
    puts "Word: #{@word.upcase}"
    puts '-' * 15
    menu
  end

  def saved_game_details
    puts '=' * 36
    puts "Guessed word: #{@guessed_word}"
    puts "You have #{@guess_count - @wrong_guess.length} trials remaining."
    puts '=' * 36
  end

  def guess_or_save
    puts 'OPTION'
    puts '1: Save game'
    puts '=' * 20
    puts 'Guess a letter : '
    input = gets.chomp.strip.downcase
    save_game if input.to_i == 1
    input
  end

  def guess_word
    word = @word
    display = '_' * word.length
    loop do
      input = guess_or_save
      display_arr = display.split('')
      saved_game_display_arr = @guessed_word.split(' ')
      display_arr = saved_game_display_arr if @saved_game
      word_arr = word.split('')
      if word.include?(input)
        if display_arr.include?(input)
          miss(input)
        else

          word_arr.each_index do |i|
            display_arr[i] = input if word_arr[i] == input
            display = display_arr.join
          end
        end
      else
        miss(input)
      end

      @guessed_word = display_arr.join(' ')
      p display_arr.join(' ')

      summary if @guess_remaining.zero?

      next unless display_arr.join == word
      won word
    end
  end
end

def main
  puts '===== HANGMAN v1.0 ====='
  play = HangMan.new
  play.menu
end

main

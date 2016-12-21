require 'byebug'

class Code
  attr_reader :pegs

  PEGS = {
    "R" => :red,
    "G" => :green,
    "B" => :blue,
    "Y" => :yellow,
    "O" => :orange,
    "P" => :purple,
  }

  def initialize(pegs)
    @pegs = pegs
  end

  def self.random
    rand_code = PEGS.keys.shuffle[0..3]
    Code.new(rand_code)
  end

  def self.parse(guess)
    guess.upcase.each_char { |peg| raise unless PEGS.include?(peg) }
    guess = guess.upcase.chars
    Code.new(guess)
  end

  # why do i need this ??
  def [](i)
    @pegs[i]
  end

  def ==(code)
    code.is_a?(Code) && (self.pegs == code.pegs)
  end

  def exact_matches(other_code)
    correct = 0
    (0..3).each do |i|
      correct += 1 if other_code.pegs[i] == self.pegs[i]
    end
    correct
  end

  def near_matches(other_code)
    matches = Hash.new(0)
    self.pegs.each_with_index do |peg, i|
      if other_code.pegs.include?(self[i])
        matches[peg] += 1 unless matches[peg] == other_code.pegs.count(peg)
      end
    end

    matches = matches.values.inject(:+)
    exact_matches = self.exact_matches(other_code)
    matches - exact_matches
  end

end

class Game
  attr_reader :secret_code

  def initialize(secret_code = Code.random)
    @secret_code = secret_code
  end

  def over?(guess, guesses)
    # debugger
    guess.pegs == secret_code.pegs || guesses == 10
  end

  def play
    puts "Make a guess (Ex: RGBY)"
    puts "Color options: R G B Y O P \n \n"

    10.times do
      guesses = 0
      guess = get_guess

      if guess == @secret_code
        puts "You win!"
        return
      end

      display_matches(guess)
    end
    puts "The secret code was #{secret_code.pegs}. Try again.."
  end

  def get_guess
    # why??
    ARGV.clear

    begin
      guess = gets.chomp
      Code.parse(guess)
    rescue
      puts "Please choose valid colors."
      puts "Color options: R G B Y O P \n \n"
      retry
    end

  end

  def display_matches(guess)
    correct = guess.exact_matches(secret_code)
    near = guess.near_matches(secret_code)
    puts "exact : #{correct} " + "near : #{near} \n \n"
  end

end


if $PROGRAM_NAME == __FILE__
  Game.new.play
end

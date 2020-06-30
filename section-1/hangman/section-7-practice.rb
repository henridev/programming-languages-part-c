## Solution template for Guess The Word practice problem (section 7)

require_relative './section-7-provided'

class ExtendedGuessTheWordGame < GuessTheWordGame
    def initialize(secret_word_class)
        super(secret_word_class)
    end
   
end

class ExtendedSecretWord < SecretWord
  def initialize word
    super(word)
    ["?", ".", "!", " "].each { |p| guess_letter! p }
  end

  def valid_guess? guess
    guess.length == 1 && guess.match(/[a-zA-Z]/)
  end
end

## Change to `false` to run the original game
if true
  ExtendedGuessTheWordGame.new(ExtendedSecretWord).play
else
  GuessTheWordGame.new(SecretWord).play
end
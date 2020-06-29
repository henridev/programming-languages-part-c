# University of Washington, Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

# 1. In your game, the player can press the ’u’ key to make the piece that is falling rotate 180 degrees.
# (Note it is normal for this to make some pieces appear to move slightly.)


# 2. In your game, instead of the pieces being randomly (and uniformly) chosen from the 7 classic pieces,
# the pieces are randomly (and uniformly) chosen from 10 pieces. They are the classic 7 and these 3:
# 22222 22222 222

class MyPiece < Piece
  
    def initialize(point_array, board)
      super(point_array, board)
    end

         # The constant All_My_Pieces should be declared here
    All_My_Pieces = [[[[0, 0], [1, 0], [0, 1], [1, 1]]],  # square (only needs one)
         rotations([[0, 0], [-1, 0], [1, 0], [0, -1]]), # T
         [[[0, 0], [-1, 0], [1, 0], [2, 0]], # long (only needs two)
         [[0, 0], [0, -1], [0, 1], [0, 2]]],
         rotations([[0, 0], [0, -1], [0, 1], [1, 1]]), # L
         rotations([[0, 0], [0, -1], [0, 1], [-1, 1]]), # inverted L
         rotations([[0, 0], [-1, 0], [0, -1], [1, -1]]), # S
         rotations([[0, 0], [1, 0], [0, -1], [-1, -1]]),
         [[0, 0], [1, 0], [0, 1], [1, 1]]] # Z

    def self.next_piece (board)
      MyPiece.new(All_My_Pieces.sample, board)
    end
end
  
class MyBoard < Board
    def initialize (game)
      super(game)
      @current_block = MyPiece.next_piece(self)
    end

    def rotate_full
      if !game_over? and @game.is_running?
        @current_block.move(0, 0, 2)
      end
      draw
    end

    def next_piece
      @current_block = MyPiece.next_piece(self)
      @current_pos = nil
    end
end
  
class MyTetris < Tetris
    def initialize
      super
    end

    # make sure we use myboard instead of board on setup
    def set_board
      @canvas = TetrisCanvas.new
      @board = MyBoard.new(self)
      @canvas.place(@board.block_size * @board.num_rows + 3,
                    @board.block_size * @board.num_columns + 6, 24, 80)       
      @board.draw
    end

    

    def key_bindings 
      super 
      # invoke in parent method with the same name 
      # as the one where this super is called in
      @root.bind('u', proc {@board.rotate_full})
    end



end



# The initial rotation for each piece is also chosen randomly.
# 3. In your game, the player can press the ’c’ key to cheat: If the score is less than 100, nothing happens.
# Else the player loses 100 points (cheating costs you) and the next piece that appears will be:
# 2
# The piece after is again chosen randomly from the 10 above (unless, of course, the player hits ’c’ while
# the \cheat piece" is falling and still has a large enough score). Hitting ’c’ multiple times while a single
# piece is falling should behave no differently than hitting it once.
# University of Washington, Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

# 1. In your game, the player can press the ’u’ key to make the piece that is falling rotate 180 degrees.
# (Note it is normal for this to make some pieces appear to move slightly.)


# 2. In your game, instead of the pieces being randomly (and uniformly) chosen from the 7 classic pieces,
# the pieces are randomly (and uniformly) chosen from 10 pieces. They are the classic 7 and these 

# 


class MyPiece < Piece
  
    def initialize(point_array, board)
      super(point_array, board)
    end

    # adding the three pieces hook longer and square with extra
    All_My_Pieces = All_Pieces + 
                    [[[[0, 0], [-2, 0], [-1, 0], [1, 0], [2, 0]], # very long (only needs two)
                    [[0, 0], [0, -2], [0, -1], [0, 1], [0, 2]]],
                    rotations([[0, 0], [0, 1], [1, 1]]), # Small L
                    rotations([[0, 0], [-1, 0], [0, -1], [0, 1], [-1, 1]]) # Square with jut
                    ]
                    
    # general -- make sure we use MyPiece and All_My_Pieces
    def self.next_piece (board, cheating=false)
      if cheating
        MyPiece.new([[[0, 0]]], board)
      else
        MyPiece.new(All_My_Pieces.sample, board)
      end
    end
  end

class MyBoard < Board
    def initialize (game)
      super(game)
      @current_block = MyPiece.next_piece(self)
      @cheating = false
    end

    # 2 -- changed the range to change depending on amount of blocks 
    def store_current
      locations = @current_block.current_rotation
      displacement = @current_block.position
      (0..(locations.size-1)).each{|index| 
        current = locations[index];
        @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
        @current_pos[index]
      }
      remove_filled
      @delay = [@delay - 2, 80].max
    end

    # 1 -- ensure full rotation
    def rotate_full
      if !game_over? and @game.is_running?
        @current_block.move(0, 0, 2)
      end
      draw
    end

     # 3 -- cheat check only cheat if score above 100 and not currently 
     # using cheat block
    def cheat
      if score >= 100 && !@cheating
        @score -= 100
        @cheating = true 
      end
    end

    def cheating
      @cheating = true 
    end

    def next_piece
      if @cheating
        @current_block = MyPiece.next_piece(self, true)
        @cheating = false
      else
        @current_block = MyPiece.next_piece(self)
      end    
      @current_pos = nil
    end


  end
  
class MyTetris < Tetris
    def initialize
      super
    end

    # general -- make sure we use myboard instead of board on setup
    def set_board
      @canvas = TetrisCanvas.new
      @board = MyBoard.new(self)
      @canvas.place(@board.block_size * @board.num_rows + 3,
                    @board.block_size * @board.num_columns + 6, 24, 80)       
      @board.draw
    end

    def key_bindings 
      super 
      @root.bind('u', proc {@board.rotate_full})
      @root.bind('c', proc {@board.cheat})
    end
end
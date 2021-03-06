require_relative 'piece'
require_relative 'board'

class Chess
  attr_accessor :board, :player

  def initialize
    @board = Board.new
    @player = :white
    @previous_board = @board
  end

  def valid_move?(move)
    if move.length == 4
      if (1..8).to_a.include?(move[1].to_i) && (1..8).to_a.include?(move[3].to_i)
        if ('a'..'h').to_a.include?(move[0]) && ('a'..'h').to_a.include?(move[2])
          return true
        end
      end
    end
    false
  end

  def player_move
    puts "#{@player}'s turn.\nWhere would you like to move?\nUse format 'a1b2' or ask for a hint with 'hint a1'."
    loop do
      #input = STDIN.gets.chomp
      input = @board.array_of_all_moves_for(@player).sample
      puts input
      if hint?(input)
        p hint_for(extract_location(input))
        redo
      end
      unless valid_move?(input)
        puts "That's not a valid move."
        redo
      end
      unless @board.piece_color_at(@board.start_location(input)) == player
        puts "That's not your piece to move."
        redo
      end
      unless @board.legal?(input)
        puts "That's not a legal move."
        redo
      end
      @previous_board = @board
      @board.move_piece(input)
      @board.promote(@board.end_location(input), knight_or_queen) if @board.promotion?(@board.end_location(input))
      if @board.check?(@player)
        puts "After that move you would be in check. Move somewhere else."
        undo_move
        redo
      end
      break
    end
  end

  def knight_or_queen
    puts "Your pawn can be promoted. What would you like? (knight/queen)"
    loop do
      input = STDIN.gets.chomp
      return :queen if input == 'queen'
      return :knight if input == 'knight'
      puts "What would you like? (knight/queen)"
    end
  end

  def change_player
    @player = @player == :white ? :black : :white
  end

  def hint?(input)
    return false unless input.length == 7
    array = input.split
    return false unless array.length == 2
    return false unless array[0] == 'hint'
    return false unless ('a'..'h').to_a.include?(array[1][0])
    return false unless (1..8).to_a.include?(array[1][1].to_i)
    true
  end

  def hint_for(loc)
    return "No piece at #{loc}." unless @board.any_piece?(loc)
    array = case @board.piece_type_at(loc)
    when :pawn
      moves = @board.array_of_legal_pawn_moves(loc)
      if @board.piece_color_at(loc) == :white
        if @board.new_loc(loc, -1, 1)
          move = @board.new_move(loc, @board.new_loc(loc, -1, 1))
          moves << move if @board.white_en_passant?(move)
        elsif @board.new_loc(loc, 1, 1)
          move = @board.new_move(loc, @board.new_loc(loc, 1, 1))
          moves << move if @board.white_en_passant?(move)
        end
      else
        if @board.new_loc(loc, -1, -1)
          move = @board.new_move(loc, @board.new_loc(loc, -1, -1))
          moves << move if @board.black_en_passant?(move)
        elsif @board.new_loc(loc, 1, -1)
         move = @board.new_move(loc, @board.new_loc(loc, 1, -1))
         moves << move if @board.black_en_passant?(move)
       end
      end
      moves
    when :knight then @board.array_of_legal_knight_moves(loc)
    when :rook then @board.array_of_legal_rook_moves(loc)
    when :bishop then @board.array_of_legal_bishop_moves(loc)
    when :queen then @board.array_of_legal_queen_moves(loc)
    when :king then @board.array_of_legal_king_moves(loc)
    end
    return "There are no moves for #{loc}." if array.empty?
    array
  end

  def extract_location(input)
    input.split[1].to_sym
  end

  def undo_move
    @board = @previous_board
  end
  
  def mate?
    return false  if @board.check?(@player)
    @previous_board = @board
    array = array_of_all_moves_for(@player)
    array.each  do |move|
      game.board.move_piece
      if @board.check?
        @board.undo_move
      else
        @board.undo_move
        return false
      end
    end
    true
  end
end

def init_game
  game = Chess.new
  loop do
    puts game.board.to_s
    white_king_dead = true
    black_king_dead = true
    game.board.each do |piece|
      white_king_dead = false if piece != nil && piece.type == :king && piece.player == :white
      black_king_dead = false if piece != nil && piece.type == :king && piece.player == :black
    end
    if white_king_dead || black_king_dead
      puts "One of the kings has died."
      break
    end
    if game.board.array_of_all_moves_for(game.player).empty?
      puts "The game ends in a tie."
      break
    end
    if game.board.mate?(game.player)
      puts "#{game.player} is in checkmate!"
      game.change_player
      puts "#{game.player} Wins!"
      break
    end
    puts "#{game.player} is in check." if game.board.check?(game.player)
    p game.board.array_of_all_moves_for(game.player)
    game.player_move
    game.change_player
  end
end

init_game

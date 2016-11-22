require_relative 'piece'

class Board
  attr_accessor :board_hash
  def initialize
    @board_hash = 
    {
    a1: Piece.new(:rook, :white, :a1),
    b1: Piece.new(:knight, :white, :b1),
    c1: Piece.new(:bishop, :white, :c1),
    d1: Piece.new(:queen, :white, :d1),
    e1: Piece.new(:king, :white, :e1),
    f1: Piece.new(:bishop, :white, :f1),
    g1: Piece.new(:knight, :white, :d1),
    h1: Piece.new(:rook, :white, :h1),
    a2: Piece.new(:pawn, :white, :a2),
    b2: Piece.new(:pawn, :white, :b2),
    c2: Piece.new(:pawn, :white, :c2),
    d2: Piece.new(:pawn, :white, :d2),
    e2: Piece.new(:pawn, :white, :e2),
    f2: Piece.new(:pawn, :white, :f2),
    g2: Piece.new(:pawn, :white, :g2),
    h2: Piece.new(:pawn, :white, :h2),
    a8: Piece.new(:rook, :black, :a8),
    b8: Piece.new(:knight, :black, :b8),
    c8: Piece.new(:bishop, :black, :c8),
    d8: Piece.new(:queen, :black, :d8),
    e8: Piece.new(:king, :black, :e8),
    f8: Piece.new(:bishop, :black, :f8),
    g8: Piece.new(:knight, :black, :g8),
    h8: Piece.new(:rook, :black, :h8),
    a7: Piece.new(:pawn, :black, :a7),
    b7: Piece.new(:pawn, :black, :b7),
    c7: Piece.new(:pawn, :black, :c7),
    d7: Piece.new(:pawn, :black, :d7),
    e7: Piece.new(:pawn, :black, :e7),
    f7: Piece.new(:pawn, :black, :f7),
    g7: Piece.new(:pawn, :black, :g7),
    h7: Piece.new(:pawn, :black, :h7)
    }
  end
  def each(&block)
    8.downto(1) do |i|
      ('a'..'h').each do |j| 
        yield(@board_state[(i.to_s + j).to_sym])
      end
    end
  end
  def to_s
    string = "\n\n"
    8.downto(1) do |numeral|
      string << numeral.to_s + ' '
      ('a'..'h').each do |alpha|
        location = "#{alpha + numeral.to_s}".to_sym
        if @board_hash[location]
          string << @board_hash[location].to_s
        else
          string << '__'
        end
        string << ' '
      end
      string << "\n\n"
    end
    string << '  '
    ('a'..'h').each { |n| string << n.to_s + '  ' }
    string
  end

  def piece_at(location)
    @board_hash[location]
  end
  def piece_type_at(location)
    board_hash[location].type
  end
  def piece_color_at(location)
    board_hash[location].player
  end
  def piece_location_at(location)
    board_hash[location].location
  end
  def piece_moved?(location)
    return true if @board_hash[location].moved > 0
    false    
  end

  def any_piece?(location)
    @board_hash[location] ? true : false
  end

  # returns the first two characters in a move
  # example: given 'a1b2' returns :a1
  def start_location(move)
    move.split(//).first(2).join('').to_sym
  end
  # returns the last two characters in a move
  # example: given 'a1b2' returns :b2
  def end_location(move)
    move.split(//).last(2).join('').to_sym
  end
  def new_move(start_location, end_location)
    start_location.to_s + end_location.to_s
  end

  def move_piece(move)
    start_loc = start_location(move)
    end_loc = end_location(move)
    @board_hash[end_loc] = @board_hash[start_loc]
    @board_hash[start_loc] = nil
    @board_hash[end_loc].location = end_loc
    @board_hash[end_loc].moved += 1
  end

  def new_loc(location, x, y)
    location = location.to_s
    alpha_hash = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
    alpha = location.split(//).first
    alpha_index = alpha_hash.find_index(alpha) + x
    return false if alpha_index > 7 || alpha_index < 0
    number = location.split(//).last.to_i + y
    return false if number > 8 || number < 1
    location = alpha_hash[alpha_index] + number.to_s
    location.to_sym
  end

# TODO add en passante
  def array_of_legal_pawn_moves(location)
    array = []
    if piece_color_at(location) == :white
      # if there's no piece directly in from of pawn
      unless any_piece?(new_loc(location, 0, 1))
        # allow it to move forward 1 space
        array << new_move(location, new_loc(location, 0, 1))
        # if there's no piece two space in front of pawn and it hasn't moved
        unless any_piece?(new_loc(location, 0, 2)) || piece_moved?(location)
          # allow pawn to move twice
          array << new_move(location, new_loc(location, 0, 2))
        end
      end
      # enemy piece on the diagnals?
      array << new_move(location, new_loc(location, 1, 1)) if any_piece?(new_loc(location, 1, 1)) && piece_color_at(new_loc(location, 1, 1)) == :black
      array << new_move(location, new_loc(location, -1, 1)) if any_piece?(new_loc(location, -1, 1)) && piece_color_at(new_loc(location, 1, 1)) == :black
      # can you take a piece en passante?
      if location.to_s.split(//).last.to_i == 5
        loc = new_loc(location, 1, 0)
        if any_piece?(loc) && piece_color_at(loc) == :black
          if @board_hash[loc].moved == 1
            array << new_move(location, new_loc(location, 1, 1))
          end
        end
        loc = new_loc(location, -1, 0)
        if any_piece?(loc) && piece_color_at(loc) == :black
          if @board_hash[loc].moved == 1
            array << new_move(location, new_loc(location, -1, 1))
          end
        end
      end
    # if the pawn being moved is black
    else
      unless any_piece?(new_loc(location, 0, -1))
        array << new_move(location, new_loc(location, 0, -1))
        unless any_piece?(new_loc(location, 0, -2)) || piece_moved?(location)
          array << new_move(location, new_loc(location, 0, -2))
        end
      end
      array << new_move(location, new_loc(location, 1, -1)) if any_piece?(new_loc(location, 1, -1)) && piece_color_at(new_loc(location, 1, -1)) == :white
      array << new_move(location, new_loc(location, -1, -1)) if any_piece?(new_loc(location, -1, -1)) && piece_color_at(new_loc(location, 1, -1)) == :white
      if location.to_s.split(//).last.to_i == 4
        loc = new_loc(location, 1, 0)
        if any_piece?(loc) && piece_color_at(loc) == :white
          if @board_hash[loc].moved == 1
            array << new_move(location, new_loc(location, 1, -1))
          end
        end
        loc = new_loc(location, -1, 0)
        if any_piece?(loc) && piece_color_at(loc) == :white
          if @board_hash[loc].moved == 1
            array << new_move(location, new_loc(location, -1, -1))
          end
        end
      end
    end
    array.sort!
  end

  def legal_pawn_move?(move)
    return array_of_legal_pawn_moves(start_location(move)).include?(move)
  end

  def x_or_y_moves(loc, x, y)
    array = []
    color = piece_color_at(loc)
    1.upto(7) do |i|
      cursor = new_loc(loc, i * x , i * y)
      return array unless cursor
      if any_piece?(cursor)
        array << new_move(loc, cursor) unless piece_color_at(cursor) == color
        return array
      else
        array << new_move(loc, cursor)
      end
    end
  end

  def array_of_legal_rook_moves(loc)
    array = []
    array << x_or_y_moves(loc, 1, 0)
    array << x_or_y_moves(loc, 0, 1)
    array << x_or_y_moves(loc, -1, 0)
    array << x_or_y_moves(loc, 0, -1)
    array.flatten!.sort!
  end

  def legal_rook_move?(move)
    array_of_legal_rook_moves(start_location(move)).include?(move)
  end

  def legal?(move)
    return false if @board_hash[start_location(move)] == nil
    case piece_type_at(start_location(move))
    when :pawn then return legal_pawn_move?(move)
    when :knight then return legal_knight_move?(move)
    when :rook then return legal_rook_move?(move)
    when :bishop then return legal_bishop_move?(move)
    when :queen then return legal_queen_move?(move)
    when :king then return legal_king_move?(move)
    end
    false
  end
end

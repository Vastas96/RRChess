require './ruby-chess/chess.rb'

# Room class, references players
class Room < ApplicationRecord
  BLACK_WIN = 'Black win!'.freeze
  WHITE_WIN = 'White win!'.freeze
  STALEMATE = 'Stalemate!'.freeze
  GAME_IN_PROGRESS = 'Game in progress.'.freeze

  attr_accessor :board

  validates :white, presence: true
  validates :black, presence: true
  # validate :check_white_and_black

  belongs_to :white, class_name: 'User', foreign_key: 'white_id'
  belongs_to :black, class_name: 'User', foreign_key: 'black_id'

  # def check_white_and_black
  # errors.add("Players can't be the same") if white == black
  # end

  after_initialize do
    if new_record?
      self.side ||= 0
      @board = ChessBoard.new
      white.set_game
      black.set_game
    end
  end

  def change_side
    update_attribute(:side, side ^ 1)
  end

  def white?(nick_name)
    side.equal?(0) && white.nick_name == nick_name.to_s
  end

  def black?(nick_name)
    side.equal?(1) && black.nick_name == nick_name.to_s
  end

  def active_player
    white_name = white.nick_name.to_sym
    black_name = black.nick_name.to_sym
    return white_name if white?(white_name)
    return black_name if black?(black_name)
  end

  def make_move(msg, nick_name)
    return false unless white?(nick_name) || black?(nick_name)
    return false unless board.make_a_move(*board.parse_move(msg[1..4]))
    change_side
  end

  def resign(user)
    if user.equal?(white)
      board.set_game_status(BLACK_WIN)
    elsif user.equal?(black)
      board.set_game_status(WHITE_WIN)
    end
  end

  def game_over?
    !board.game_status.eql?(GAME_IN_PROGRESS)
  end

  def finish
    return if board.game_status.eql?(GAME_IN_PROGRESS)
    white.set_zero
    black.set_zero
  end
end

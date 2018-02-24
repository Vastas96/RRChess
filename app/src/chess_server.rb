require './app/src/server.rb'
require 'singleton'

# Chess server class that manipulates users
class ChessServer < Server
  include Singleton

  def initialize
    super(8080)
  end

  def handle_message(msg, nick_name)
    return unless clients.key?(nick_name)
    case msg[0].to_i
    when 1
      handle_make_move_request(msg, nick_name)
    when 2
      handle_new_game_request(nick_name)
    when 3
      handle_resign_request(nick_name)
    end
  end

  def handle_make_move_request(msg, nick_name)
    return unless rooms.key?(nick_name)
    room = rooms.fetch(nick_name)
    return unless room.make_move(msg, nick_name)
    clients.fetch(nick_name).puts 'Made move!'
    clients.fetch(room.active_player).puts msg
    return unless room.game_over?
    handle_game_over(room)
  end

  def handle_game_over(room)
    room.finish
    # Get names of the players
    white = room.white.nick_name.to_sym
    black = room.black.nick_name.to_sym

    # Notify connected clients about game end
    notify_end_game(white, black, room.board)

    delete_room(room, white, black)
  end

  def delete_room(room, white, black)
    # Delete room from db
    room.destroy
    # Delete Hash entries that reference to room
    rooms.delete(white)
    rooms.delete(black)
  end

  def handle_new_game_request(nick_name)
    return if rooms.key?(nick_name)
    users.each do |other_name, other_user|
      next if other_name.equal?(nick_name)
      next unless other_user.state.equal?(2)
      return create_room(other_name, nick_name)
    end
    users.fetch(nick_name).set_seek
    send_to_all("#{nick_name}: Is seeking for a game")
  end

  def create_room(white, black)
    room = Room.create(white: users.fetch(white), black: users.fetch(black))
    rooms[white] = room
    rooms[black] = room
    # puts "created room for #{nick_name} and #{other_name}!"

    notify_new_game(white, black)
  end

  def notify_new_game(white, black)
    wclient = clients.fetch(white)
    bclient = clients.fetch(black)

    wclient.puts "You were paired with #{black}@ You're white!"
    bclient.puts "You were paired with #{white}@ You're black!"
  end

  def notify_end_game(white, black, board)
    wclient = clients.fetch(white)
    bclient = clients.fetch(black)

    if board.white_win?
      wclient.puts('You win!')
      bclient.puts('You lost!')
    elsif board.black_win?
      bclient.puts('You win!')
      wclient.puts('You lost!')
    else
      wclient.puts('Draw!')
      bclient.puts('Draw!')
    end
  end

  def handle_resign_request(nick_name)
    return unless rooms.key?(nick_name)
    room = rooms.fetch(nick_name)
    room.resign(users.fetch(nick_name))
    handle_game_over(room)
  end
end

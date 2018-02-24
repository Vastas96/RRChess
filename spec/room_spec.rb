require 'rails_helper.rb'

describe Room do
  fixtures :users

  context 'initialization' do
    before do
      @white = users(:white)
      @black = users(:black)
      @white_name = @white.nick_name.to_sym
      @black_name = @black.nick_name.to_sym
      @room = Room.create(white: @white, black: @black)
    end
    it 'Can contain 2 players' do
      expect(@room.white).to eql(@white)
      expect(@room.black).to eql(@black)
    end
    # side white is represented as 0
    it 'After creation side to move should be white' do
      expect(@room.side).to be(0)
    end
    it 'Change side' do
      @room.change_side
      expect(@room.side).to eql(1)
    end
    it 'Should return active player' do
      expect(@room.active_player).to eql('white'.to_sym)
      @room.change_side
      expect(@room.active_player).to eql('black'.to_sym)
    end
    it 'Should return true if it is white to move' do
      expect(@room.white?(@room.white.nick_name)).to be true
    end
    it 'Should return true if it is black to move' do
      @room.change_side
      expect(@room.black?(@room.black.nick_name)).to be true
    end
    it 'Should let white player resign' do
      @room.resign(@white)
      expect(@room.board.game_status).to eql(BLACK_WIN)
    end
    it 'Should let black player resign' do
      @room.resign(@black)
      expect(@room.board.game_status).to eql(WHITE_WIN)
    end
    it 'Should only let finish game if it has ended' do
      expect(@room.finish).to be nil
    end
    it 'Should do something with players after game is over' do
      # fastest check mate
      @room.make_move('1e2e4', @white_name)
      @room.make_move('1e7e5', @black_name)
      @room.make_move('1d1f3', @white_name)
      @room.make_move('1f7f5', @black_name)
      @room.make_move('1f1c4', @white_name)
      @room.make_move('1f5e4', @black_name)
      @room.make_move('1f3f7', @white_name)
      expect(@room.board.game_status).to eql(WHITE_WIN)
      @room.finish
      expect(@white.state).to eql(0)
      expect(@black.state).to eql(0)
    end
  end
end

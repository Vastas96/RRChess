require 'rails_helper.rb'

require 'rspec/expectations'
require 'rspec/mocks'

# Custom matchers
RSpec::Matchers.define :be_in_game do
  match do |actual|
    actual.state.equal?(1)
  end
end
RSpec::Matchers.define :be_white_move do
  match do |actual|
    actual.side.equal?(0)
  end
end
RSpec::Matchers.define :be_black_move do
  match do |actual|
    actual.side.equal?(1)
  end
end
RSpec::Matchers.define :contain_players do |expected|
  match do |actual|
    (actual.white.equal?(expected[0]) || actual.black.equal?(expected[0])) &&
      (actual.white.equal?(expected[1]) || actual.black.equal?(expected[1]))
  end
end
# I can not test server completely because it runs in a loop
# I can only test before it begins work

describe ChessServer do
  BLACK_WIN = 'Black win!'.freeze
  WHITE_WIN = 'White win!'.freeze
  STALEMATE = 'Stalemate!'.freeze
  GAME_IN_PROGRESS = 'Game in progress.'.freeze

  before do
    @server = ChessServer.instance
  end
  context 'message handling' do
    before do
      @nick1 = 'tester1'.to_sym
      @nick2 = 'tester2'.to_sym
      @nick3 = 'tester3'.to_sym
      @nick4 = 'tester4'.to_sym
      @clnt1 = double('Client', gets: 'tester1', puts: '', close: true)
      @clnt2 = double('Client', gets: 'tester2', puts: '', close: true)
      @clnt3 = double('Client', gets: 'tester3', puts: '', close: true)
      @clnt4 = double('Client', gets: 'tester4', puts: '', close: true)
      @server.init_client @clnt1
      @server.init_client @clnt4
      @server.init_client @clnt2
      @server.init_client @clnt3

      @stubbed_board = double('Board', game_status: STALEMATE, white_win?: false, black_win?: false, make_a_move: true, parse_move: true)
    end
    # 8
    it 'Server should detect multiple new game requests and not pair with himself' do
      @server.handle_message('254dasda', @nick1)
      @server.handle_message('2', @nick1)
      expect(@server.rooms[@nick1]).to be(nil)
    end
    # 9 Used matcher
    it 'Server should change users state after he send seek new game msg' do
      @server.handle_message('2', @nick3)
      expect(@server.users[@nick3].state).to eql(2)
    end
    # 10 Used matchers
    # 13 Custom matcher
    it 'Server should change user state after the pairing' do
      @server.handle_message('2asd', @nick1)
      @server.handle_message('2', @nick2)
      expect(@server.users[@nick1]).to be_in_game
      expect(@server.users[@nick2]).to be_in_game
    end
    # 14
    it 'Server should send same messages to all clients' do
      expect(@clnt1).to receive(:puts).with('test')
      expect(@clnt2).to receive(:puts).with('test')
      @server.send_to_all('test')
    end
    # 15 Used matcher
    it 'Server should catch unhandable message' do
      expect(@server.handle_message('Unhandable message', @nick1)).to be_nil
    end

    it 'Everyone should receive message when someone seeks for a game' do
      expect(@clnt1).to receive(:puts).with("#{@nick1}: Is seeking for a game")
      expect(@clnt2).to receive(:puts).with("#{@nick1}: Is seeking for a game")
      expect(@clnt3).to receive(:puts).with("#{@nick1}: Is seeking for a game")
      expect(@clnt4).to receive(:puts).with("#{@nick1}: Is seeking for a game")

      @server.handle_message('2asd', @nick1)
    end
    it 'Server should create room containing paired players 1' do
      expect(@clnt1).to receive(:puts).with('You were paired with tester2@ You\'re white!')
      expect(@clnt2).to receive(:puts).with('You were paired with tester1@ You\'re black!')
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)
      user1 = @server.users.fetch(@nick1)
      user2 = @server.users.fetch(@nick2)
      expect(@server.rooms[@nick1]).to contain_players([user1, user2])
    end
    # 11
    it 'Server should create room containing paired players 2' do
      expect(@clnt4).to receive(:puts).with('You were paired with tester1@ You\'re white!')
      expect(@clnt1).to receive(:puts).with('You were paired with tester4@ You\'re black!')
      @server.handle_message('2', @nick4)
      @server.handle_message('2', @nick1)
      user4 = @server.users.fetch(@nick4)
      user1 = @server.users.fetch(@nick1)
      expect(@server.rooms[@nick4]).to contain_players([user4, user1])
    end
    # 12
    it 'Server should create room containing paired players 3' do
      expect(@clnt3).to receive(:puts).with('You were paired with tester4@ You\'re black!')
      expect(@clnt4).to receive(:puts).with('You were paired with tester3@ You\'re white!')
      @server.handle_message('2125 asdasdf', @nick4)
      @server.handle_message('2', @nick3)
      user3 = @server.users.fetch(@nick3)
      user4 = @server.users.fetch(@nick4)
      expect(@server.rooms[@nick3]).to contain_players([user3, user4])
    end
    # 16 Custom matcher
    it 'Server should relay moves properly' do
      @server.handle_message('2151dsadwq', @nick1)
      @server.handle_message('2', @nick2)

      expect(@server.rooms[@nick1]).to be_white_move

      expect(@clnt1).to receive(:puts).with('Made move!')
      expect(@clnt2).to receive(:puts).with('1e2e4')

      @server.handle_message('1e2e4', @nick1)

      expect(@server.rooms[@nick1]).to be_black_move

      expect(@clnt2).to receive(:puts).with('Made move!')
      expect(@clnt1).to receive(:puts).with('1e7e5')
      @server.handle_message('1e7e5', @nick2)
      expect(@server.rooms[@nick1]).to be_white_move
    end
    # 17
    it 'Server should notice if its not your move' do
      @server.handle_message('215 asd', @nick1)
      @server.handle_message('2', @nick2)
      expect(@server.handle_message('1e2e4', @nick2)).to be(nil)
    end
    # 18
    it 'Server should not let start new game if player is already in game' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      expect(@server.handle_message('2', @nick2)).to be(nil)
    end
    # 19
    it 'Server should notice if user does not exist' do
      expect(@server.handle_message('3NotHere', @nick1)).to be(nil)
      expect(@server.handle_message('4NotHere', @nick1)).to be(nil)
    end
    # 20
    it 'Server should not let user make move if he\'s not in game' do
      expect(@server.handle_message('1e2e4', @nick1)).to be(nil)
    end
    it 'Server closes properly' do
      @server.clients.each_value do |clnt|
        expect(clnt).to receive(:close)
      end
      @server.clean_up
      expect(@server.tcp_server.closed?).to be true
    end
    it 'Server should handle white win' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      expect(@clnt1).to receive(:puts).with('You win!')
      expect(@clnt2).to receive(:puts).with('You lost!')

      expect(@clnt1).not_to receive(:puts).with('You lost!')
      expect(@clnt2).not_to receive(:puts).with('You win!')

      # Fast white mate
      @server.handle_message('1e2e4', @nick1)
      @server.handle_message('1e7e5', @nick2)
      @server.handle_message('1d1f3', @nick1)
      @server.handle_message('1f7f5', @nick2)
      @server.handle_message('1f1c4', @nick1)
      @server.handle_message('1f5e4', @nick2)
      @server.handle_message('1f3f7', @nick1)
    end
    it 'Server should handle black win' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      expect(@clnt1).to receive(:puts).with('You lost!')
      expect(@clnt2).to receive(:puts).with('You win!')

      # Fast black mate
      @server.handle_message('1f2f4', @nick1)
      @server.handle_message('1e7e6', @nick2)
      @server.handle_message('1g2g4', @nick1)
      @server.handle_message('1d8h4', @nick2)
    end
    it 'Should handle draw' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      expect(@clnt1).to receive(:puts).with('Draw!')
      expect(@clnt2).to receive(:puts).with('Draw!')

      # Getting room instance
      room = @server.rooms[@nick1]
      # Changing board to stubbed Board
      room.board = @stubbed_board
      @server.handle_message('1e2e4', @nick1)
    end

    it 'Server should delete room after game is over' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      # Getting room instance
      room = @server.rooms[@nick1]
      # Making sure room exists in db
      expect(Room.exists?(room.id)).to be true
      # Changing board to stubbed Board
      room.board = @stubbed_board
      # instantly ending game by entering any move
      @server.handle_message('1e2e4', @nick1)

      # Expecting for room to be destroyed
      expect(Room.exists?(room.id)).to be false
      # Expecting hashes to be cleared
      expect(@server.rooms[@nick1]).to eql(nil)
      expect(@server.rooms[@nick2]).to eql(nil)
    end

    it 'Server should handle resign' do
      @server.handle_message('2', @nick1)
      @server.handle_message('2', @nick2)

      expect(@clnt1).to receive(:puts).with('You win!')
      expect(@clnt2).to receive(:puts).with('You lost!')

      @server.handle_message('3', @nick2)
    end
    after do
      @server.users.each_value(&:set_zero)
    end
  end
  after do
    @server.reset
  end
end

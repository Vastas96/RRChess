require 'rails_helper'

RSpec.describe "rooms/show", type: :view do

  fixtures :users

  before(:each) do
    @white = users(:white)
    @black = users(:black)
    @room = assign(:room, Room.create!(
      :white => @white,
      :black => @black
    ))
    @board = double('Board', get_fen: 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R')
    # ChessServer.instance.reset
  end
  it "renders attributes in <p>" do
    expect(@room.board).not_to receive(:get_fen)
    render
    expect(rendered).to match(@white.nick_name)
    expect(rendered).to match(@black.nick_name)
  end
  it "renders attributes in <p>" do
    @room.board = @board
    ChessServer.instance.rooms[@white.nick_name.to_sym] = @room
    expect(@board).to receive(:get_fen)
    render
    expect(rendered).to match(@white.nick_name)
    expect(rendered).to match(@black.nick_name)
  end
end

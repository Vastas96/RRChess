require 'rails_helper'

RSpec.describe "rooms/new", type: :view do
  fixtures :users

  before(:each) do
    @white = users(:white)
    @black = users(:black)
    assign(:room, Room.new(
      :white => @white,
      :black => @black,
    ))
  end

  it "renders new room form" do
    render

    assert_select "form[action=?][method=?]", rooms_path, "post" do

      assert_select "input[name=?]", "room[white_id]"

      assert_select "input[name=?]", "room[black_id]"

      assert_select "input[name=?]", "room[side]"
    end
  end
end
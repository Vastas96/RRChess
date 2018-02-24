require 'rails_helper'
=begin
RSpec.describe "rooms/edit", type: :view do
  before(:each) do
    @room = assign(:room, Room.create!(
      :white_id => 1,
      :black_id => 1,
      :side => 1
    ))
  end

  it "renders the edit room form" do
    render

    assert_select "form[action=?][method=?]", room_path(@room), "post" do

      assert_select "input[name=?]", "room[white_id]"

      assert_select "input[name=?]", "room[black_id]"

      assert_select "input[name=?]", "room[side]"
    end
  end
end
=end
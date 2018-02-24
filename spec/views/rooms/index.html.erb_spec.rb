require 'rails_helper'
=begin
RSpec.describe "rooms/index", type: :view do
  before(:each) do
    assign(:rooms, [
      Room.create!(
        :white_id => 2,
        :black_id => 3,
        :side => 4
      ),
      Room.create!(
        :white_id => 2,
        :black_id => 3,
        :side => 4
      )
    ])
  end

  it "renders a list of rooms" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
=end
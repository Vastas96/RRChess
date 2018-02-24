require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :nick_name => "Nick Name",
        :rating => 2,
        :state => 3
      ),
      User.create!(
        :nick_name => "Nick Name",
        :rating => 2,
        :state => 3
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => "Nick Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end

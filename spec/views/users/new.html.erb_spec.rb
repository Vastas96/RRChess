require 'rails_helper'

RSpec.describe "users/new", type: :view do
  before(:each) do
    assign(:user, User.new(
      :nick_name => "MyString",
      :rating => 1,
      :state => 1
    ))
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", users_path, "post" do

      assert_select "input[name=?]", "user[nick_name]"

      assert_select "input[name=?]", "user[rating]"

      assert_select "input[name=?]", "user[state]"
    end
  end
end

require 'rails_helper'

RSpec.describe "users/edit", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :nick_name => "MyString",
      :rating => 1,
      :state => 1
    ))
  end

  it "renders the edit user form" do
    render

    assert_select "form[action=?][method=?]", user_path(@user), "post" do

      assert_select "input[name=?]", "user[nick_name]"

      assert_select "input[name=?]", "user[rating]"

      assert_select "input[name=?]", "user[state]"
    end
  end
end

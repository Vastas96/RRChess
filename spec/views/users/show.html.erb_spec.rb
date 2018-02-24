require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :nick_name => "Nick Name",
      :rating => 2,
      :state => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Nick Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end

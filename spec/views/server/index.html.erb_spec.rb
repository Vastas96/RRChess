require 'rails_helper'

RSpec.describe "server/index.html.erb", type: :view do
  before(:each) do
    assign(:server, ChessServer.instance)
    @clnt1 = double('Client', gets: 'tester1', puts: '', close: true)
  end

  it "renders a statistic" do
    render
    assert_select "tr>td", :text => "Users online: 0", :count => 1
    assert_select "tr>td", :text => "Games in progress: 0", :count => 1
  end
  it "renders a statistic 2" do
  	ChessServer.instance.init_client(@clnt1)
    render
    assert_select "tr>td", :text => "Users online: 1", :count => 1
    assert_select "tr>td", :text => "Games in progress: 0", :count => 1
  end
end

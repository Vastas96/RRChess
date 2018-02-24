require 'rails_helper'

RSpec.describe ServerController, type: :controller do

  INITIALIZED = 'initialized'.freeze
  RUNNING = 'running'.freeze

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #start" do
    it "returns http redirect" do
      get :start
      expect(response).to have_http_status(:redirect)
      sleep(0.1)
      expect(ChessServer.instance.state).to eql(RUNNING)
    end
  end

  describe "GET #restart" do
    before do
      sleep(0.5)
    end
    it "returns http redirect" do
      expect(ChessServer.instance).to receive(:restart)
      get :restart
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #stats" do
    it "returns http success" do
      get :stats
      expect(response).to have_http_status(:success)
    end
  end

end
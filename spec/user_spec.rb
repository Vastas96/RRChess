require 'rails_helper.rb'

describe User do
  fixtures :users

  before do
    @user = users(:white)
  end
  context 'initialization' do
    it 'User should have name set correctly' do
      expect(@user.nick_name).to eql('white')
    end
    it 'User should have state set to 0' do
      expect(@user.state).to be(0)
    end
    it 'User should have rating set to 1250' do
      expect(@user.rating).to be(1250)
    end
    it 'User should set seek' do
      @user.set_seek
      expect(@user.state).to eql(2)
    end
    it 'User should set game' do
      @user.set_game
      expect(@user.state).to eql(1)
    end
    it 'User should set zero' do
      @user.set_zero
      expect(@user.state).to eql(0)
    end
  end
end

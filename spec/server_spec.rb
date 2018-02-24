require 'rails_helper.rb'

require 'rspec/expectations'

RSpec::Matchers.define :be_good do
  match do |actual|
    actual.addr[1] == 8070 &&
      actual.addr[2] == '0.0.0.0' &&
      actual.addr[0] == 'AF_INET'
  end
end
# I can not test server completely because it runs in a loop
# I can only test before it begins work

describe Server do
  before do
    @server = Server.new(8070)
  end
  context 'initialization' do
    it 'client count should be 0' do
      expect(@server.clients).to be_empty
    end
    it 'room count should be 0' do
      expect(@server.rooms).to be_empty
    end
    it 'TCPServer should not be closed' do
      expect(@server.tcp_server.closed?).to be false
    end

    it 'TCPServer should be properly initialized' do
      expect(@server.tcp_server).to be_good
    end
  end

  context 'Client initialization' do
    before do
      @client = double('Client', gets: 'name', puts: true)
      # Client2 enter the same name to check if Server notices duplicate
      @client2 = double('Client', gets: 'name')
    end
    it 'Server should properly init client' do
      expect(@client).to receive(:puts).with('Connection established!')
      expect(@client).not_to receive(:close)
      expect(@server.init_client(@client)).to eql('name'.to_sym)
    end
    it 'Server should detect if user has already logged in' do
      @server.init_client(@client)

      expect(@client2).to receive(:puts).with('This user has already logged in')
      expect(@client2).not_to receive(:puts).with('Connection established!')
      expect(@client2).to receive(:close)
      @server.init_client(@client2)
    end
    it 'Server should throw error if handle_message gets called' do
    	expect{@server.handle_message}.to raise_error(RuntimeError,
    		'handle_message is not implemented in this class!')
    end
  end

  context 'Restart' do
    before do
      @client1 = double('Client', gets: 'name1', puts: true)
      @client2 = double('Client', gets: 'name2', puts: true)
      @server.init_client(@client1)
      @server.init_client(@client2)
    end
    it 'Should close clients and rest' do
      expect(@client1).to receive(:close)
      expect(@client2).to receive(:close)
      expect(@server.clients.size).to eql(2)
      @server.restart
      expect(@server.clients.size).to eql(0)
    end
  end
  after do
    @server.tcp_server.close
  end
end

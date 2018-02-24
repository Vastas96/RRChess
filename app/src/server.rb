require 'socket'
require 'rails/all'

# Server class that accepts and handles clients
class Server
  attr_reader :clients, :users, :rooms, :tcp_server, :state

  INITIALIZED = 'initialized'.freeze
  RUNNING = 'running'.freeze

  def initialize(port)
    @users = {}
    @clients = {}
    @rooms = {}
    @tcp_server = TCPServer.new '0.0.0.0', port
    @state = INITIALIZED
  end

  def run
    @state = RUNNING
    loop do
      Thread.start(tcp_server.accept) do |client|
        nick_name = init_client(client)
        Thread.kill self if nick_name.empty?
        listen_user_messages(nick_name)
      end
    end.join
  end

  def init_client(client)
    nick_name = client.gets.chomp.to_sym

    if clients.key?(nick_name)
      client.puts 'This user has already logged in'
      client.close
      return ''
    end

    @clients[nick_name] = client
    @users[nick_name] = User.find_or_create_by(nick_name: nick_name)
    client.puts 'Connection established!'
    nick_name
  end

  def listen_user_messages(nick_name)
    loop do
      msg = clients[nick_name].gets
      handle_message(msg, nick_name)
    end
  end

  MESS = 'handle_message is not implemented in this class!'.freeze

  def handle_message
    raise MESS
  end

  def send_to_all(msg)
    clients.each_value do |other_client|
      other_client.puts msg
    end
  end

  def clean_up
    clients.each_value(&:close)
    tcp_server.close
  end

  def reset
    @users = {}
    @clients = {}
    @rooms = {}
  end

  def restart
    port = @tcp_server.addr[1]
    clean_up
    reset
    @tcp_server = TCPServer.new '0.0.0.0', port
    @state = INITIALIZED
  end
end

# server = Server.new(8080)
# server.init_client("test")
# server.run

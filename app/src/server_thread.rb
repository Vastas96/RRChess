require 'singleton'

# Singleton class to contain server's thread
class ServerThread
  include Singleton
  attr_reader :thread

  def start(server)
    @thread = Thread.new do
      server.run
    end
  end
end

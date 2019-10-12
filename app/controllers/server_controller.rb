require './app/src/chess_server.rb'
require './app/src/server_thread.rb'

# Control panel for Server
class ServerController < ApplicationController
  attr_reader :server

  INITIALIZED = 'initialized'.freeze
  RUNNING = 'running'.freeze

  def index
    @server = ChessServer.instance
  end

  def stats
    @server = ChessServer.instance
  end

  def start
    @server = ChessServer.instance
    redirect_to action: 'index'
    return if @server.state == RUNNING
    ServerThread.instance.start(@server)
  end

  def restart
    @server = ChessServer.instance
    Thread.kill ServerThread.instance.thread
    @server.restart
    start
  end
end

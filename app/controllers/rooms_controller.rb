require './app/src/chess_server.rb'

# Handles Room model
class RoomsController < ApplicationController
  before_action :set_room, only: %i[show edit update destroy]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    # @room = Room.find_by(id: params[:id])
    begin
      @room = ChessServer.instance.rooms.fetch(@room.white.nick_name.to_sym)
      @board = @room.board
    rescue
    end
    respond_to do |template|
      template.js { render layout: false, content_type: 'text/javascript' }
      template.html
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit; end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html do
        redirect_to rooms_url,
                    notice: 'Room was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end
end

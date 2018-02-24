# User class
class User < ApplicationRecord
  READY = 0
  IN_GAME = 1
  SEEKING = 2

  validates :nick_name, length: { minimum: 3 }, presence: true

  after_initialize do
    self.state ||= READY if new_record?
  end

  def set_seek
    update_attribute(:state, SEEKING)
  end

  def set_game
    update_attribute(:state, IN_GAME)
  end

  def set_zero
    update_attribute(:state, READY)
  end
end

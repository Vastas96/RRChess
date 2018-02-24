class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.integer :white_id
      t.integer :black_id
      t.integer :side

      t.timestamps
    end
  end
end

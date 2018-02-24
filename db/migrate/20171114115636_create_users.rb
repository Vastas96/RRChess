class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :nick_name
      t.integer :rating
      t.integer :state

	  add_index :nick_name, unique: true

      t.timestamps
    end
  end
end

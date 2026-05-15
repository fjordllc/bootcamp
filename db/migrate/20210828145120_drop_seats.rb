class DropSeats < ActiveRecord::Migration[6.1]
  def change
    drop_table :seats do |t|
      t.string :name
      t.timestamps
    end
  end
end

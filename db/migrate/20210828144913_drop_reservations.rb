class DropReservations < ActiveRecord::Migration[6.1]
  def change
    drop_table :reservations do |t|
      t.date :date
      t.integer :user_id, null: false, foreign_key: true
      t.integer :seat_id, null: false, foreign_key: true
      t.index :reservations, %i[seat_id date], unique: true
      t.timestamps
    end
  end
end

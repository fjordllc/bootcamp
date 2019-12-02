# frozen_string_literal: true

class CreateReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :reservations do |t|
      t.date :date
      t.integer :user_id, null: false, foreign_key: true
      t.integer :seat_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end

# frozen_string_literal: true

class AddIndexToReservations < ActiveRecord::Migration[6.0]
  def change
    add_index :reservations, [:seat_id, :date], unique: true
  end
end

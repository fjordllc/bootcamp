# frozen_string_literal: true

class AddIndexToReports < ActiveRecord::Migration[6.0]
  def change
    change_table :reports do |t|
      t.index [:user_id, :title], unique: true
      t.index [:user_id, :reported_on], unique: true
    end
  end
end

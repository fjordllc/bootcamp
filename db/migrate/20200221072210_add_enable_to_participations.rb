# frozen_string_literal: true

class AddEnableToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :enable, :boolean, default: false, null: false
  end
end

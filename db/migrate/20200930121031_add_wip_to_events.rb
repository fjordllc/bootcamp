# frozen_string_literal: true

class AddWipToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :wip, :boolean, null: false, default: false
  end
end

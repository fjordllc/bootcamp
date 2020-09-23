# frozen_string_literal: true

class AddSatisfactionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :satisfaction, :integer
  end
end

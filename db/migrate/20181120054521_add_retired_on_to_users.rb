# frozen_string_literal: true

class AddRetiredOnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :retired_on, :date
  end
end

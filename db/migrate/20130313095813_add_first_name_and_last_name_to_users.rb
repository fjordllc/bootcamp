# frozen_string_literal: true

class AddFirstNameAndLastNameToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :first_name
      t.string :last_name
    end
  end
end

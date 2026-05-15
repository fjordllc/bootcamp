# frozen_string_literal: true

class AddColumnsForSignupToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.integer :job
      t.string :organization
      t.integer :os
      t.integer :study_place
      t.integer :experience
      t.string :how_did_you_know
    end
  end
end

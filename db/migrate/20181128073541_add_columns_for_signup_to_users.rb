# frozen_string_literal: true

class AddColumnsForSignupToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :job, :integer
    add_column :users, :organization, :string
    add_column :users, :os, :integer
    add_column :users, :study_place, :integer
    add_column :users, :experience, :integer
    add_column :users, :how_did_you_know, :string
  end
end

# frozen_string_literal: true

class CreateSwitchletFlags < ActiveRecord::Migration[6.1]
  def change
    create_table :switchlet_flags do |t|
      t.string  :name,        null: false
      t.boolean :enabled,     null: false, default: false
      t.text    :description
      t.timestamps
    end
    add_index :switchlet_flags, :name, unique: true
  end
end

# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :reactions do |t|
      t.references :user, foreign_key: true
      t.references :reactionable, polymorphic: true
      t.integer :kind, default: 0, null: false

      t.timestamps
    end
  end
end

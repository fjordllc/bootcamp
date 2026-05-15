# frozen_string_literal: true

class AddIndexToLearnings < ActiveRecord::Migration[6.0]
  def change
    add_index :learnings, %i[user_id practice_id], unique: true
  end
end

# frozen_string_literal: true

class AddIndexToReactions < ActiveRecord::Migration[6.0]
  def change
    add_index :reactions, [:user_id, :reactionable_id, :reactionable_type, :kind], unique: true, name: 'index_reactions_on_reactionable'
  end
end

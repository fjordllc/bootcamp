# frozen_string_literal: true

class AddIndexToReactions < ActiveRecord::Migration[6.0]
  def change
    # インデックス名の長さ制限を超えてしまうため短い名前にする
    add_index :reactions,
              %i[user_id reactionable_id reactionable_type kind],
              unique: true,
              name: 'index_reactions_on_reactionable_u_k'
  end
end

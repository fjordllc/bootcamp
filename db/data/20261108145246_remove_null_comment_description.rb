# frozen_string_literal: true

class RemoveNullCommentDescription < ActiveRecord::Migration[8.1]
  def up
    Comment.where(description: nil).update_all(description: "")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

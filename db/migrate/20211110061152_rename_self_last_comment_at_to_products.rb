class RenameSelfLastCommentAtToProducts < ActiveRecord::Migration[6.1]
  def change
    rename_column :products, :self_last_comment_at, :self_last_commented_at
  end
end

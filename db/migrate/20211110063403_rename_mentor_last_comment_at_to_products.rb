class RenameMentorLastCommentAtToProducts < ActiveRecord::Migration[6.1]
  def change
    rename_column :products, :mentor_last_comment_at, :mentor_last_commented_at
  end
end

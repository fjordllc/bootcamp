class RemoveCommentUserIdIndexFromComments < ActiveRecord::Migration[7.2]
  def change
    # このインデックスを追加したマイグレーションファイルは存在しない
    # マイグレーションをやり直せるようにするために`if_exists: true`が必要
    remove_index :comments, :user_id, name: 'comment_user_id', if_exists: true
  end
end

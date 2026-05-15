class AddSelfLastCommentAtColumnAndMentorLastCommentAtColumnToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :self_last_comment_at, :datetime

    add_column :products, :mentor_last_comment_at, :datetime
  end
end

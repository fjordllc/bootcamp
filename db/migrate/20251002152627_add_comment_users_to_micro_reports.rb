class AddCommentUsersToMicroReports < ActiveRecord::Migration[6.1]
  def change
    add_column :micro_reports, :comment_user_id, :bigint
    add_foreign_key :micro_reports, :users, column: :comment_user_id
  end
end

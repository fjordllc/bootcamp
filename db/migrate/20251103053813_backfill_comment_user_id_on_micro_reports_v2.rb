class BackfillCommentUserIdOnMicroReportsV2 < ActiveRecord::Migration[6.1]
  def up
    MicroReport.where(comment_user_id: nil).find_each do |report|
      next if report.user_id.blank?
      report.update_column(:comment_user_id, report.user_id)
    end
  end

  def down
    MicroReport.update_all(comment_user_id: nil)
  end
end

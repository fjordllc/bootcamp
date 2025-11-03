class BackfillCommentUserIdOnMicroReports < ActiveRecord::Migration[6.1]
  def up
    MicroReport.where(comment_user_id: nil).find_each do |report|
      report.update!(comment_user_id: report.user_id)
    end
  end

  def down
    MicroReport.update_all(comment_user_id: nil)
  end
end

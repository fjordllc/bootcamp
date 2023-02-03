# frozen_string_literal: true

class AddSentStudentFollowupMessageToUsers < ActiveRecord::Migration[6.1]
  def up
    User.where('created_at <= ?', Time.current.ago(31.days)).or(User.where.not(hibernated_at: nil)).find_each do |user|
      user.assign_attributes(sent_student_followup_message: true)
      user.save(context: :followup_message)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

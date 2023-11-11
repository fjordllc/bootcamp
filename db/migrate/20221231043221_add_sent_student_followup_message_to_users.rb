class AddSentStudentFollowupMessageToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sent_student_followup_message, :boolean, default: false
  end
end

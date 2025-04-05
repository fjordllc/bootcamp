class AddSentStudentBeforeAutoRetireMailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sent_student_before_auto_retire_mail, :boolean, default: false
  end
end

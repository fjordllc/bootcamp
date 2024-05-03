class AddNotNullToCorporateTrainings < ActiveRecord::Migration[6.1]
  def change
    change_column_null :corporate_trainings, :company_name, false
    change_column_null :corporate_trainings, :name, false
    change_column_null :corporate_trainings, :email, false
    change_column_null :corporate_trainings, :meeting_date1, false
    change_column_null :corporate_trainings, :meeting_date2, false
    change_column_null :corporate_trainings, :meeting_date3, false
    change_column_null :corporate_trainings, :participants_count, false
    change_column_null :corporate_trainings, :training_duration, false
    change_column_null :corporate_trainings, :how_did_you_hear, false
  end
end

class AddUniqueIndexToSurveyAnswers < ActiveRecord::Migration[6.1]
  def change
    add_index :survey_answers, [:survey_id, :user_id], unique: true
  end
end

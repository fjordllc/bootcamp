class CreateSurveyAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_answers do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

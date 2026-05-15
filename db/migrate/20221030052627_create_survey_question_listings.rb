class CreateSurveyQuestionListings < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_question_listings do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :survey_question, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateSurveyQuestionAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_question_answers do |t|
      t.references :survey_answer, null: false, foreign_key: true
      t.references :survey_question, null: false, foreign_key: true
      t.text :answer
      t.text :reason

      t.timestamps
    end
  end
end

class CreatePracticeQuizAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_quiz_answers do |t|
      t.references :practice_quiz_attempt, null: false, foreign_key: true
      t.references :practice_quiz_choice, null: false, foreign_key: true
      t.boolean :correct, null: false, default: false

      t.timestamps
    end
  end
end

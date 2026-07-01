class CreatePracticeQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_quiz_questions do |t|
      t.references :practice_quiz, null: false, foreign_key: true
      t.integer :question_type, null: false
      t.text :body, null: false
      t.text :explanation
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end

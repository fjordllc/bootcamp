class CreatePracticeQuizChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_quiz_choices do |t|
      t.references :practice_quiz_question, null: false, foreign_key: true
      t.string :body, null: false
      t.boolean :correct, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end

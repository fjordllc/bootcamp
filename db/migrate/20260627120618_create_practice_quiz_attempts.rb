class CreatePracticeQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_quiz_attempts do |t|
      t.references :practice_quiz, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :submitted_at, null: false
      t.boolean :passed, null: false, default: false

      t.timestamps

      t.index %i[practice_quiz_id user_id submitted_at], name: 'index_practice_quiz_attempts_on_quiz_user_submitted_at'
    end
  end
end

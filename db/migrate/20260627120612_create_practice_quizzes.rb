class CreatePracticeQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_quizzes do |t|
      t.references :practice, null: false, foreign_key: true, index: { unique: true }
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end

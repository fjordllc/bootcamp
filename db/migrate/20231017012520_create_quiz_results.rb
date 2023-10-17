class CreateQuizResults < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_results do |t|
      t.integer :score
      t.references :quiz, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

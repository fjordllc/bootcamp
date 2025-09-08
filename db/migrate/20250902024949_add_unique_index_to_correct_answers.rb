class AddUniqueIndexToCorrectAnswers < ActiveRecord::Migration[6.1]
  def change
    add_index :answers, [:question_id, :type], unique: true
  end
end

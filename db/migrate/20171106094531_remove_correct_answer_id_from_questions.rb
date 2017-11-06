class RemoveCorrectAnswerIdFromQuestions < ActiveRecord::Migration[5.1]
  def change
    remove_column :questions, :correct_answer_id, :integer
  end
end

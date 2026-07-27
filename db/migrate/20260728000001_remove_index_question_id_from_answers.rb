class RemoveIndexQuestionIdFromAnswers < ActiveRecord::Migration[8.1]
  def change
    remove_index :answers, :question_id, name: "index_answers_on_question_id"
  end
end

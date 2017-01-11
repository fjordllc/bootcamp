class AddCorrectAnswerIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :correct_answer_id, :integer
    remove_column :questions, :resolve
  end
end

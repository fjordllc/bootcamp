# frozen_string_literal: true

class AddCorrectAnswerIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :correct_answer_id, :integer
    remove_column :questions, :resolve
  end
end

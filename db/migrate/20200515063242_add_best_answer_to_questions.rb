# frozen_string_literal: true

class AddBestAnswerToQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :best_answer, :integer
  end
end

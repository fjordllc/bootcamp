# frozen_string_literal: true

class RemoveAiAnswerFromQuestions < ActiveRecord::Migration[7.1]
  def change
    remove_column :questions, :ai_answer, :text
  end
end

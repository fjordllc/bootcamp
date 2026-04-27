# frozen_string_literal: tru

class AddAiAnswerToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :ai_answer, :text
  end
end

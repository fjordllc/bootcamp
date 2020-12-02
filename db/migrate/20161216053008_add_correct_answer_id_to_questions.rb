# frozen_string_literal: true

class AddCorrectAnswerIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    change_table :questions, bulk: true do |t|
      t.integer :correct_answer_id
      t.remove :resolve
    end
  end
end

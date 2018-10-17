# frozen_string_literal: true

class AddPracticeIdToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_reference :questions, :practice, foreign_key: true, index: true
  end
end

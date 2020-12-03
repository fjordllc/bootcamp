# frozen_string_literal: true

class AddCorrectAnswerIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        change_table :questions, bulk: true do |t|
          t.integer :correct_answer_id
          t.remove :resolve
        end
      end

      dir.down do
        change_table :questions, bulk: true do |t|
          t.remove :correct_answer_id
          t.boolean :resolve
        end
      end
    end
  end
end

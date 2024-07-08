class AddSubmissionAnswerIdToPractices < ActiveRecord::Migration[6.1]
  def change
    add_reference :practices, :submission_answer, null: true, foreign_key: true
  end
end

class AddModelSubmissionIdToPractices < ActiveRecord::Migration[6.1]
  def change
    add_reference :practices, :model_submission, null: true, foreign_key: true
  end
end

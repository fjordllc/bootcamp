class AddModelAnswerIdToPractices < ActiveRecord::Migration[6.1]
  def change
    add_reference :practices, :model_answer, null: true, foreign_key: true
  end
end

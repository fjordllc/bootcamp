class AddNeedModelAnswerToPractice < ActiveRecord::Migration[6.1]
  def change
    add_column :practices, :need_model_answer, :boolean, null: false, default: false
  end
end

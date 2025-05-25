class ChangeDatatypeAnswerOfFAQ < ActiveRecord::Migration[6.1]
  def change
    change_column :faqs, :answer, :text, null: false, unique: true
  end
end

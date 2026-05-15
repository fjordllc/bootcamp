class CreateFaqs < ActiveRecord::Migration[6.1]
  def change
    create_table :faqs do |t|
      t.string :answer, null: false, unique: true
      t.string :question, null: false, unique: true

      t.timestamps
    end
    add_index :faqs, :question, unique: true
    add_index :faqs, [:answer, :question], unique: true
  end
end

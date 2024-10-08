class CreateFaqsCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :faqs_categories do |t|
      t.references :faq, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end

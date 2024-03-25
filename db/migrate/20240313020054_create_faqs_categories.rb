class CreateFaqsCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :faqs_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end

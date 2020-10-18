class CreateJoinTableCategoryPractice < ActiveRecord::Migration[6.0]
  def change
    create_join_table :categories, :practices do |t|
      t.index [:category_id, :practice_id]
      t.index [:practice_id, :category_id]
    end

    add_foreign_key :categories_practices, :categories
    add_foreign_key :categories_practices, :practices
  end
end

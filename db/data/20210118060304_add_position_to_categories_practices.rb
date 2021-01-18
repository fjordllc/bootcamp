# frozen_string_literal: true

class AddPositionToCategoriesPractices < ActiveRecord::Migration[6.0]
  def up
    CategoriesPractice.acts_as_list_no_update do
      Practice.all.find_each do |practice|
        CategoriesPractice.where(practice_id: practice.id).find_each do |categories_practice|
          categories_practice.position = practice.position
        end
      end
      ActiveRecord::Base.transaction do
        Category.all.find_each do |category|
          CategoriesPractice.where(category_id: category.id).order(:position).each.with_index(1) do |categories_practice, index|
            categories_practice.update!(position: index, created_at: Time.current, updated_at: Time.current)
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

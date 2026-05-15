# frozen_string_literal: true

class ChangeCategoryPositionToSequential < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.transaction do
      Category.acts_as_list_no_update do
        Category.order(:position).each.with_index(1) do |category, index|
          category.update!(position: index)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

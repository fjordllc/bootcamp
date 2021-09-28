# frozen_string_literal: true

class AddCommentedAtInProducts < ActiveRecord::Migration[6.1]
  def up
    Product.all.includes(:comments).each do |product|
      next if product.comments.blank?

      product.update!(commented_at: product.comments.last.updated_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

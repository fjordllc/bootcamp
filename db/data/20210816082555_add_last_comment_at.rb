# frozen_string_literal: true

class AddLastCommentAt < ActiveRecord::Migration[6.1]
  def up
    products = Product.where(self_last_comment_at: nil).where(mentor_last_comment_at: nil)
    products.each do |product|
      next unless product.comments.size.positive?

      product.comments.each do |comment|
        if comment.user.mentor
          product.mentor_last_comment_at = comment.updated_at
        elsif comment.user == product.user
          product.self_last_comment_at = comment.updated_at
        end
      end
      product.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

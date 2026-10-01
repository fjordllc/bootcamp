# frozen_string_literal: true

class CreateProductAiReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :product_ai_reviews do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.text :content
      t.timestamps
    end
  end
end

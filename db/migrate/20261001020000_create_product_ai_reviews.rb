# frozen_string_literal: true

class CreateProductAiReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :product_ai_reviews do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.text :content
      t.string :status, null: false, default: 'pending'
      t.string :source_fingerprint, null: false
      t.string :generation, null: false
      t.string :model, null: false
      t.datetime :generated_at
      t.timestamps
    end
  end
end

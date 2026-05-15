# frozen_string_literal: true

class AddPublishedAtToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :published_at, :datetime
  end
end

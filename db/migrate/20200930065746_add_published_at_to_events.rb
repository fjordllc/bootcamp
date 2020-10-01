# frozen_string_literal: true

class AddPublishedAtToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :published_at, :datetime
  end
end

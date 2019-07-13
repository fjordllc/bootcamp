# frozen_string_literal: true

class AddPublishedAtToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :published_at, :datetime
  end
end

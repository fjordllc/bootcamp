class AddPublishedAtToRegularEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :regular_events, :published_at, :datetime
  end
end

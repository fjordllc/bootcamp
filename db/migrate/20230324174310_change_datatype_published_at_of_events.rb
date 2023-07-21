class ChangeDatatypePublishedAtOfEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :published_at, :datetime
  end
end

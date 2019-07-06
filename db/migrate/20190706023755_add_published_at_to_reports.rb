class AddPublishedAtToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :publised_at, :datetime
  end
end

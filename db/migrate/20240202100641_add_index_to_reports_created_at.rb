class AddIndexToReportsCreatedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :reports, :created_at
  end
end

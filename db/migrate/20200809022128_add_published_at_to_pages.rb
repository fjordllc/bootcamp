class AddPublishedAtToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :published_at, :datetime
  end
end

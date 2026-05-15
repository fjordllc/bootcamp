class AddWipAndPublishedAtToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :wip, :boolean, default: false, null: false
    add_column :articles, :published_at, :datetime
  end
end

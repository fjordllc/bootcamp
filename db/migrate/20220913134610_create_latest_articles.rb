class CreateLatestArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :latest_articles do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :summary
      t.datetime :published_at

      t.timestamps
    end
  end
end

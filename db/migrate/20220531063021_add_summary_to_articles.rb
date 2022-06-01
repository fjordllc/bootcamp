class AddSummaryToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :summary, :text
  end
end

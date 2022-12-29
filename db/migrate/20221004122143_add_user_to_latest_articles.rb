class AddUserToLatestArticles < ActiveRecord::Migration[6.1]
  def change
    add_reference :latest_articles, :user, null: false, foreign_key: true
  end
end

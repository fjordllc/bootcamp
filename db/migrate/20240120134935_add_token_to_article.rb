class AddTokenToArticle < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :token, :string
  end
end

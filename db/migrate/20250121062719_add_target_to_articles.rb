class AddTargetToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :target, :integer
  end
end

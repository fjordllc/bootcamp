class AddLaunchArticleToWorks < ActiveRecord::Migration[6.1]
  def change
    add_column :works, :launch_article, :string
  end
end

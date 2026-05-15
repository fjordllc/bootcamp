class AddBlogUrlToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :blog_url, :string
  end
end

class AddReleaseBlogToWorks < ActiveRecord::Migration[6.1]
  def change
    add_column :works, :release_blog, :string
  end
end

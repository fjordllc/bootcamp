class RestoreColumnLimits < ActiveRecord::Migration[6.1]
  def change
    change_column :categories, :name, :string, limit: 255
    change_column :categories, :slug, :string, limit: 255

    change_column :companies, :name, :string, limit: 255
    change_column :companies, :website, :string, limit: 255

    change_column :users, :login_name, :string, limit: 255, null: false
    change_column :users, :email, :string, limit: 255
    change_column :users, :crypted_password, :string, limit: 255
    change_column :users, :salt, :string, limit: 255
    change_column :users, :remember_me_token, :string, limit: 255
    change_column :users, :twitter_account, :string, limit: 255
    change_column :users, :facebook_url, :string, limit: 255
    change_column :users, :blog_url, :string, limit: 255
    change_column :users, :github_account, :string, limit: 255
  end
end

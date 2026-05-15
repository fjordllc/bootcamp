class AddProfileNameAndProfileJobAndProfileTextToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :profile_name, :string
    add_column :users, :profile_job, :string
    add_column :users, :profile_text, :text
  end
end

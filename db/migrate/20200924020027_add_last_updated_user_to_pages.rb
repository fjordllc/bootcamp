class AddLastUpdatedUserToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :last_updated_user_id, :bigint
  end
end

class RemoveUserIdFromResponses < ActiveRecord::Migration[6.1]
  def change
    remove_column :responses, :user_id, :integer
  end
end

class RemoveIndexFromInquiries < ActiveRecord::Migration[7.2]
  def change
    remove_index :inquiries, :action_completed
  end
end

class AddActionCompletedToInquiries < ActiveRecord::Migration[6.1]
  def change
    add_column :inquiries, :action_completed, :boolean, default: false, null: false
    add_index  :inquiries, :action_completed
  end
end

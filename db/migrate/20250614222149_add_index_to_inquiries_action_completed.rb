class AddIndexToInquiriesActionCompleted < ActiveRecord::Migration[6.1]
  def change
    add_index :inquiries, :action_completed
  end
end

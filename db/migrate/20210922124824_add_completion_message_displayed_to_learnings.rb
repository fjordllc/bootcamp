class AddCompletionMessageDisplayedToLearnings < ActiveRecord::Migration[6.1]
  def change
    add_column :learnings, :completion_message_displayed, :boolean, null: false, default: false
  end
end

class AddSentMessageAfterThirtyDaysToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sent_message_after_thirty_days, :boolean, default: false
  end
end

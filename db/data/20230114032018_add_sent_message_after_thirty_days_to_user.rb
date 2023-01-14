# frozen_string_literal: true

class AddSentMessageAfterThirtyDaysToUser < ActiveRecord::Migration[6.1]
  def up
    User.where('created_at <= ?', Time.current.ago(31.days)).find_each do |user|
      user.assign_attributes(sent_message_after_thirty_days: true)
      user.save(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

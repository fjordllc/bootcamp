# frozen_string_literal: true

class ConvertInviteUrlOfTimesUrlToChannelUrl < ActiveRecord::Migration[6.1]
  def up
    User.where.not(times_url: nil).find_each(&:convert_to_channel_url!)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

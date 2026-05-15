# frozen_string_literal: true

class AddUnsubscribeEmailToken < ActiveRecord::Migration[6.0]
  def up
    User.transaction do
      User.where(unsubscribe_email_token: nil).find_each do |user|
        user.unsubscribe_email_token = SecureRandom.urlsafe_base64
        user.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

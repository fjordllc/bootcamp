# frozen_string_literal: true

class AddUnsubscribeEmailTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :unsubscribe_email_token, :string
  end
end

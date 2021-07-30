# frozen_string_literal: true

class RemoveSlackAccountAndSlackParticipationFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :slack_account, :string
    remove_column :users, :slack_participation, :boolean, default: true, null: false
  end
end

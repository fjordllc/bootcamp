# frozen_string_literal: true

class AddSlackChannelToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :slack_channel, :string
  end
end

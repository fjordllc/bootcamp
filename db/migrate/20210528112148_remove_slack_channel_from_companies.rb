class RemoveSlackChannelFromCompanies < ActiveRecord::Migration[6.1]
  def change
    remove_column :companies, :slack_channel, :string
  end
end

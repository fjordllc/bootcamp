class AddTrialPeriodToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :trial_period, :integer
  end
end

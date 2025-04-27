class AddReferralSourceToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :referral_source, :integer
    add_column :users, :other_referral_source, :text
  end
end

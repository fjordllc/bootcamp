class CreateDiscordProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_profiles do |t|
      t.references :user, foreign_key: true
      t.string :account_name
      t.string :times_url
      t.string :times_id
      t.timestamps
    end
  end
end

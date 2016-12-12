class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name,                   null: false
      t.string :name_phonetic,          null: false
      t.string :email,                  null: false
      t.string :occupation,             null: false
      t.string :division
      t.string :work_place,             null: false
      t.string :has_mac,                null: false
      t.string :work_time,              null: false
      t.string :work_days,              null: false
      t.string :programming_experience, null: false
      t.string :twitter_url
      t.string :facebook_url
      t.string :blog_url
      t.string :github_account
      t.text :application_reason,       null: false
      t.boolean :user_policy_agreed,     default: false, null: false
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end

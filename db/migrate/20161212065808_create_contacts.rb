# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.string :name,                       null: false
      t.string :name_phonetic,              null: false
      t.string :email,                      null: false
      t.integer :occupation_cd,             null: false, default: 0
      t.string :division
      t.integer :location_cd,               null: false, default: 0
      t.integer :has_mac_cd,                null: false, default: 0
      t.string :work_time,                  null: false
      t.string :work_days,                  null: false
      t.integer :programming_experience_cd, null: false, default: 0
      t.string :twitter_url
      t.string :facebook_url
      t.string :blog_url
      t.string :github_account
      t.text :application_reason,           null: false
      t.boolean :user_policy_agreed,        default: false, null: false
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end

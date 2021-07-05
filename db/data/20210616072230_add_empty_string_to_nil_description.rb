# frozen_string_literal: true

class AddEmptyStringToNilDescription < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      if user.description.nil?
        user.description = '自己紹介文はありません。'
        user.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

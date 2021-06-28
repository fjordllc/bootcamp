# frozen_string_literal: true

class AddEmptyStringToNilDescription < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      user.update!(description: '自己紹介文はありません。') if user.description.nil?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

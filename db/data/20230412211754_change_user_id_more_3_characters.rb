# frozen_string_literal: true

class ChangeUserIdMore3Characters < ActiveRecord::Migration[6.1]
  def up
    User.where('LENGTH(login_name) < ?', 3).find_each do |user|
      user.login_name = user.login_name.ljust(3, '0')
      user.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

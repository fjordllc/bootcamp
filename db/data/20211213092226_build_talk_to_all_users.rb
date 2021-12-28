# frozen_string_literal: true

class BuildTalkToAllUsers < ActiveRecord::Migration[6.1]
  def up
    User.all.each do |user|
      user.create_talk!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

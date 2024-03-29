# frozen_string_literal: true

class BuildTalkToAllUsers < ActiveRecord::Migration[6.1]
  def up
    User.all.find_each(&:create_talk!)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class UpdateSadStreak < ActiveRecord::Migration[6.1]
  def up
    User.order(:id).each(&:update_sad_streak)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

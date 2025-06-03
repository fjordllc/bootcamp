# frozen_string_literal: true

class UpdateNegativeStreak < ActiveRecord::Migration[6.1]
  def up
    User.order(:id).each(&:update_negative_streak)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

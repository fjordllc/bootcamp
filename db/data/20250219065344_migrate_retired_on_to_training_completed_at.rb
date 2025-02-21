# frozen_string_literal: true

class MigrateRetiredOnToTrainingCompletedAt < ActiveRecord::Migration[6.1]
  def up
    User.trainees.each do |user|
      user.update!(training_completed_at: user.retired_on.to_datetime, retired_on: nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

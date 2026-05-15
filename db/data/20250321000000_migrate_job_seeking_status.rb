# frozen_string_literal: true

class MigrateJobSeekingStatus < ActiveRecord::Migration[6.1]
  def up
    User.where(job_seeking: true).find_each do |user|
      user.update!(career_path: 1)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

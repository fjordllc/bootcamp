# frozen_string_literal: true

class ReplaceRepliedWithActionCompletedInTalks < ActiveRecord::Migration[6.1]
  def up
    sql = <<~SQL
      UPDATE talks
      SET action_completed = NOT unreplied
    SQL

    ActiveRecord::Base.connection.execute sql
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class DeleteDuplicateChecks < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      DELETE FROM checks
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY checkable_id, checkable_type
                   ORDER BY created_at ASC, id ASC
                 ) AS row_number
          FROM checks
        ) duplicate_checks
        WHERE duplicate_checks.row_number > 1
      )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

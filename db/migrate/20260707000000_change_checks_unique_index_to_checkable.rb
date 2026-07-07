# frozen_string_literal: true

class ChangeChecksUniqueIndexToCheckable < ActiveRecord::Migration[8.1]
  def up
    delete_duplicate_checks

    remove_index :checks, name: 'index_checks_on_user_id_and_checkable_id_and_checkable_type'
    add_index :checks, %i[checkable_id checkable_type], unique: true
  end

  def down
    remove_index :checks, %i[checkable_id checkable_type]
    add_index :checks, %i[user_id checkable_id checkable_type],
              unique: true,
              name: 'index_checks_on_user_id_and_checkable_id_and_checkable_type'
  end

  private

  def delete_duplicate_checks
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
end

# frozen_string_literal: true

class AddUniqueIndexToReportTemplatesUserId < ActiveRecord::Migration[8.1]
  def up
    remove_duplicate_report_templates

    remove_index :report_templates, :user_id
    add_index :report_templates, :user_id, unique: true
  end

  def down
    remove_index :report_templates, :user_id
    add_index :report_templates, :user_id
  end

  private

  def remove_duplicate_report_templates
    execute <<~SQL.squish
      DELETE FROM report_templates
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY user_id
                   ORDER BY id ASC
                 ) AS row_number
          FROM report_templates
          WHERE user_id IS NOT NULL
        ) AS ranked_templates
        WHERE ranked_templates.row_number > 1
      )
    SQL
  end
end

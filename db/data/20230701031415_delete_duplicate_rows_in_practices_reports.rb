# frozen_string_literal: true

class DeleteDuplicateRowsInPracticesReports < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.connection.execute(<<~SQL)
      DELETE FROM practices_reports
      WHERE ctid NOT IN (
        SELECT min(ctid)
        FROM practices_reports
        GROUP BY practice_id, report_id
      );
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

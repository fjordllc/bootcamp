class ChangePracticeIdReferencesToBigint < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :learnings, :practices if foreign_key_exists?(:learnings, :practices)
    remove_foreign_key :practices_reports, :practices if foreign_key_exists?(:practices_reports, :practices)
    remove_foreign_key :skipped_practices, :practices if foreign_key_exists?(:skipped_practices, :practices)

    change_column :learnings, :practice_id, :bigint
    change_column :practices_reports, :practice_id, :bigint
    change_column :skipped_practices, :practice_id, :bigint

    add_foreign_key :learnings, :practices
    add_foreign_key :practices_reports, :practices
    add_foreign_key :skipped_practices, :practices
  end
  
  def down
    remove_foreign_key :learnings,  :practices if foreign_key_exists?(:learnings, :practices)
    remove_foreign_key :practices_reports, :practices if foreign_key_exists?(:practices_reports, :practices)
    remove_foreign_key :skipped_practices, :practices if foreign_key_exists?(:skipped_practices, :practices)

    change_column :learnings, :practice_id, :integer
    change_column :practices_reports, :practice_id, :integer
    change_column :skipped_practices, :practice_id, :integer

    add_foreign_key :learnings, :practices
    add_foreign_key :practices_reports, :practices
    add_foreign_key :skipped_practices, :practices
  end
end

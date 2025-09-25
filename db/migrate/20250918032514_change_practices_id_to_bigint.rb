class ChangePracticesIdToBigint < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :movies, :practices if foreign_key_exists?(:movies, :practices)
    remove_foreign_key :learnings, :practices if foreign_key_exists?(:learnings, :practices)
    remove_foreign_key :practices_reports, :practices if foreign_key_exists?(:practices_reports, :practices)
    remove_foreign_key :skipped_practices, :practices if foreign_key_exists?(:skipped_practices, :practices)
    remove_foreign_key :practices, :practices, column: :source_id if foreign_key_exists?(:practices, :practices, column: :source_id)
    remove_foreign_key :categories_practices, :practices if foreign_key_exists?(:categories_practices, :practices)
    remove_foreign_key :coding_tests, :practices if foreign_key_exists?(:coding_tests, :practices)
    remove_foreign_key :learning_minute_statistics, :practices if foreign_key_exists?(:learning_minute_statistics, :practices)
    remove_foreign_key :pages, :practices if foreign_key_exists?(:pages, :practices)
    remove_foreign_key :practices_books, :practices if foreign_key_exists?(:practices_books, :practices)
    remove_foreign_key :practices_movies, :practices if foreign_key_exists?(:practices_movies, :practices)
    remove_foreign_key :products, :practices if foreign_key_exists?(:products, :practices)
    remove_foreign_key :questions, :practices if foreign_key_exists?(:questions, :practices)
    remove_foreign_key :submission_answers, :practices if foreign_key_exists?(:submission_answers, :practices)

    execute "ALTER TABLE practices ALTER COLUMN id TYPE bigint;"
    execute "ALTER TABLE practices ALTER COLUMN source_id TYPE bigint;" if column_exists?(:practices, :source_id)

    add_foreign_key :movies, :practices
    add_foreign_key :learnings, :practices
    add_foreign_key :practices_reports, :practices
    add_foreign_key :skipped_practices, :practices
    add_foreign_key :practices, :practices, column: :source_id if column_exists?(:practices, :source_id)
    add_foreign_key :categories_practices, :practices
    add_foreign_key :coding_tests, :practices
    add_foreign_key :learning_minute_statistics, :practices
    add_foreign_key :pages, :practices
    add_foreign_key :practices_books, :practices
    add_foreign_key :practices_movies, :practices
    add_foreign_key :products, :practices
    add_foreign_key :questions, :practices
    add_foreign_key :submission_answers, :practices
  end

  def down
    remove_foreign_key :movies, :practices
    remove_foreign_key :learnings, :practices
    remove_foreign_key :practices_reports, :practices
    remove_foreign_key :skipped_practices, :practices
    remove_foreign_key :practices, :practices, column: :source_id
    remove_foreign_key :categories_practices, :practices
    remove_foreign_key :coding_tests, :practices
    remove_foreign_key :learning_minute_statistics, :practices
    remove_foreign_key :pages, :practices
    remove_foreign_key :practices_books, :practices
    remove_foreign_key :practices_movies, :practices
    remove_foreign_key :products, :practices
    remove_foreign_key :questions, :practices
    remove_foreign_key :submission_answers, :practices

    execute "ALTER TABLE practices ALTER COLUMN id TYPE integer;"
    execute "ALTER TABLE practices ALTER COLUMN source_id TYPE integer;" if column_exists?(:practices, :source_id)

    add_foreign_key :movies, :practices
    add_foreign_key :learnings, :practices
    add_foreign_key :practices_reports, :practices
    add_foreign_key :skipped_practices, :practices
    add_foreign_key :practices, :practices, column: :source_id if column_exists?(:practices, :source_id)
    add_foreign_key :categories_practices, :practices
    add_foreign_key :coding_tests, :practices
    add_foreign_key :learning_minute_statistics, :practices
    add_foreign_key :pages, :practices
    add_foreign_key :practices_books, :practices
    add_foreign_key :practices_movies, :practices
    add_foreign_key :products, :practices
    add_foreign_key :questions, :practices
    add_foreign_key :submission_answers, :practices
  end
end

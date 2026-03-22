# frozen_string_literal: true

class AddPgBigmGinIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Searcher::Configurationの検索対象カラムに対応
  INDEXES = {
    practices: %i[title description goal],
    users: %i[login_name name name_kana description],
    reports: %i[title description],
    products: %i[body],
    announcements: %i[title description],
    pages: %i[title body],
    questions: %i[title description],
    answers: %i[description],
    comments: %i[description],
    events: %i[title description],
    regular_events: %i[title description],
    pair_works: %i[title description]
  }.freeze

  def up
    return unless pg_bigm_available?

    INDEXES.each do |table, columns|
      columns.each do |column|
        index_name = "index_#{table}_on_#{column}_bigm"
        next if index_exists?(table, column, name: index_name)

        execute <<~SQL
          CREATE INDEX CONCURRENTLY #{index_name}
          ON #{table}
          USING gin (#{column} gin_bigm_ops)
        SQL
      end
    end
  end

  def down
    INDEXES.each do |table, columns|
      columns.each do |column|
        index_name = "index_#{table}_on_#{column}_bigm"
        execute "DROP INDEX CONCURRENTLY IF EXISTS #{index_name}"
      end
    end
  end

  private

  def pg_bigm_available?
    result = execute("SELECT COUNT(*) FROM pg_extension WHERE extname = 'pg_bigm'")
    result.first["count"].to_i.positive?
  rescue StandardError
    false
  end
end

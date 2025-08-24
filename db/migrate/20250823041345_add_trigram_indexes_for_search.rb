class AddTrigramIndexesForSearch < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    safe_add_trgm_index :announcements, :title
    safe_add_trgm_index :announcements, :body

    safe_add_trgm_index :practices, :title
    safe_add_trgm_index :practices, :description

    safe_add_trgm_index :reports, :title
    safe_add_trgm_index :reports, :description

    safe_add_trgm_index :products, :title
    safe_add_trgm_index :products, :body

    safe_add_trgm_index :questions, :title
    safe_add_trgm_index :questions, :description

    safe_add_trgm_index :answers, :body

    safe_add_trgm_index :pages, :title
    safe_add_trgm_index :pages, :body

    safe_add_trgm_index :events, :title
    safe_add_trgm_index :events, :description

    safe_add_trgm_index :regular_events, :title
    safe_add_trgm_index :regular_events, :description

    safe_add_trgm_index :comments, :body

    safe_add_trgm_index :users, :login_name
    safe_add_trgm_index :users, :name
    safe_add_trgm_index :users, :description
  end

  private

  def safe_add_trgm_index(table, column)
    return unless table_exists?(table) && column_exists?(table, column)

    index_name = index_name(table, column)
    return if index_exists?(table, column, name: index_name)

    say "Adding trigram GIN index on #{table}.#{column} -> #{index_name}"
    add_index table, column, using: :gin, opclass: :gin_trgm_ops, name: index_name, algorithm: :concurrently
  end

  def index_name(table, column)
    "index_#{table}_on_#{column}_trgm"
  end
end

# frozen_string_literal: true

class EnablePgBigmExtension < ActiveRecord::Migration[8.1]
  def up
    return unless pg_bigm_installable?

    execute "CREATE EXTENSION IF NOT EXISTS pg_bigm"
  end

  def down
    execute "DROP EXTENSION IF EXISTS pg_bigm"
  rescue ActiveRecord::StatementInvalid
    # pg_bigmが存在しない環境では無視
  end

  private

  def pg_bigm_installable?
    result = execute("SELECT COUNT(*) FROM pg_available_extensions WHERE name = 'pg_bigm'")
    result.first["count"].to_i.positive?
  rescue ActiveRecord::StatementInvalid
    false
  end
end

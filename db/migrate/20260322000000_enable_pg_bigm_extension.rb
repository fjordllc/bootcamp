# frozen_string_literal: true

class EnablePgBigmExtension < ActiveRecord::Migration[8.1]
  def up
    enable_extension 'pg_bigm'
  rescue StandardError => e
    # pg_bigmがインストールされていない環境（CI等）ではスキップ
    say "pg_bigm extension not available, skipping: #{e.message.lines.first.strip}"
  end

  def down
    disable_extension 'pg_bigm'
  rescue ActiveRecord::StatementInvalid
    nil
  end
end

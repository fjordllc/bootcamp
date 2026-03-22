# frozen_string_literal: true

class EnablePgBigmExtension < ActiveRecord::Migration[8.1]
  def change
    execute "CREATE EXTENSION IF NOT EXISTS pg_bigm"
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Notice: pg_bigm extension could not be enabled."
    Rails.logger.warn "Error details: #{e.message}"
  end
end

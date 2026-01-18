# frozen_string_literal: true

class EnableVectorExtension < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    return if extension_already_enabled?

    enable_extension 'vector'
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.message.include?('vector')

    Rails.logger.warn '[SmartSearch] pgvector extension not available, skipping'
  end

  private

  def extension_already_enabled?
    result = execute("SELECT 1 FROM pg_extension WHERE extname = 'vector'")
    result.any?
  rescue ActiveRecord::StatementInvalid
    false
  end
end

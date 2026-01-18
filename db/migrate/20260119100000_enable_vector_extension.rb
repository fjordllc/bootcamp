# frozen_string_literal: true

class EnableVectorExtension < ActiveRecord::Migration[8.1]
  def change
    return if extension_already_enabled? || !vector_available?

    enable_extension 'vector'
  end

  private

  def extension_already_enabled?
    result = execute("SELECT 1 FROM pg_extension WHERE extname = 'vector'")
    result.any?
  rescue ActiveRecord::StatementInvalid
    false
  end

  def vector_available?
    result = execute("SELECT 1 FROM pg_available_extensions WHERE name = 'vector'")
    result.any?
  rescue ActiveRecord::StatementInvalid
    false
  end
end

# frozen_string_literal: true

class EnableVectorExtension < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    enable_extension 'vector'

    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "Notice: pgvector extension could not be enabled."
      Rails.logger.warn "Error details: #{e.message}"
  end
end


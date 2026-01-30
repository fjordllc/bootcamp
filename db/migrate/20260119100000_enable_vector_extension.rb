# frozen_string_literal: true

class EnableVectorExtension < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'vector'
  rescue ActiveRecord::StatementInvalid
    # pgvector is not available on this PostgreSQL server, skip
  end
end

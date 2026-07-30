# frozen_string_literal: true

class InspectEmptyBuzz < ActiveRecord::Migration[8.1]
  def up
    file_path = Rails.root.join('db/fixtures/files/buzzes/production-buzz.csv')
    now = Time.current
    list = []
    CSV.foreach(file_path, headers: true).with_index(1) do |row, i|
      Rails.logger.info "[buzz-migration] Row #{i}: #{row.to_h.inspect}"
      list << {
        title: row['title'],
        url: row['url'],
        published_at: row['published_at'],
        created_at: now,
        updated_at: now
      }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

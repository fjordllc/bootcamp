# frozen_string_literal: true

class AddBlogPostsToBuzzes < ActiveRecord::Migration[8.1]
  def up
    file_path = Rails.root.join('db/fixtures/files/buzzes/production-buzz.csv')
    now = Time.current
    list = []
    CSV.foreach(file_path, headers: true) do |row|
      list << {
        title: row['title'],
        url: row['url'],
        published_at: row['published_at'],
        created_at: now,
        updated_at: now
      }
    end
    
    ActiveRecord::Base.transaction do
      list.each do |attr| 
        Buzz.create!(attr)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

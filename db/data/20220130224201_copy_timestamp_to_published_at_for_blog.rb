# frozen_string_literal: true

class CopyTimestampToPublishedAtForBlog < ActiveRecord::Migration[6.1]
  def up
    Articles.where(wip: false).where(published_at: nil).find_each do |article|
      article.published_at = article.created_at
      article.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

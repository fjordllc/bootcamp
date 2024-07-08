# frozen_string_literal: true

class AddArticlesWithSecureToken < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  
  def up
    Article.where(wip: true).find_each do |article|
      article.update!(token: SecureRandom.urlsafe_base64)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class AddUserToArticle < ActiveRecord::Migration[6.1]
  def up
    Article.update(
      user: User.find_by(login_name: 'komagata')
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

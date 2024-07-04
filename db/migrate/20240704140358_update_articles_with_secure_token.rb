class UpdateArticlesWithSecureToken < ActiveRecord::Migration[6.1]
  def up
    Article.reset_column_information
    Article.find_each do |article|
      article.update_columns(token: SecureRandom.urlsafe_base64)
    end
  end

  def down
    Article.update_all(token: nil)
  end
end

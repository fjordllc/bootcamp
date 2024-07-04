class UpdateArticlesWithSecureToken < ActiveRecord::Migration[6.1]
  def up
    Article.where(wip: true).find_each do |article|
      article.update(token: SecureRandom.urlsafe_base64)
    end
  end
end

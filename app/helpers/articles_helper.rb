# frozen_string_literal: true

module ArticlesHelper
  def contributor
    User.admins.or(User.mentor).pluck(:login_name, :id).sort
  end

  def thumbnail_blank?(article)
    !article.thumbnail.attached? && article.thumbnail_type == 'prepared_thumbnail'
  end
end

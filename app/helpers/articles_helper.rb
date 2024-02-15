# frozen_string_literal: true

module ArticlesHelper
  def contributor
    User.admins.or(User.mentor).pluck(:login_name, :id).sort
  end

  def thumbnail_blank?(article)
    !article.thumbnail.attached? && article.thumbnail_type == 'prepared_thumbnail'
  end

  def ogp_image_url(image_url)
    base_url = "#{request.protocol}#{request.host_with_port}"
    base_url + image_url
  end
end

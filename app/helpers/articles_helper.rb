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

  def meta_robots_tag
    content = logged_in? ? 'none' : 'noindex, nofollow'
    tag.meta(name: 'robots', content:)
  end

  def feature_tag?(article)
    article.tags.pluck(:name).include?('注目の記事')
  end
end

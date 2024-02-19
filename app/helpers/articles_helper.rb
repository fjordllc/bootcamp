# frozen_string_literal: true

module ArticlesHelper
  def contributor
    User.admins.or(User.mentor).pluck(:login_name, :id).sort
  end

  def display_thumbnail(article)
    if article.thumbnail.attached? && article.prepared_thumbnail?
      image_tag article.prepared_thumbnail_url, class: 'article__image'
    elsif !thumbnail_blank?(article)
      image_tag article.selected_thumbnail_url, class: 'article__image'
    end
  end

  def ogp_image_url(image_url)
    base_url = "#{request.protocol}#{request.host_with_port}"
    base_url + image_url
  end

  private

  def thumbnail_blank?(article)
    !article.thumbnail.attached? && article.thumbnail_type == 'prepared_thumbnail'
  end
end

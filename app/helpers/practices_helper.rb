# frozen_string_literal: true

module PracticesHelper
  OGP_SIZE = [1200, 630].freeze

  def all_books
    Book.all.collect { |book| [book.id, book.title] }
  end

  def practice_ogp_variant(image)
    image.variant(resize_to_fill: OGP_SIZE).processed
  end

  def practice_ogp_image_tag(image, **options)
    image_tag(practice_ogp_variant(image), **options)
  end

  def practice_ogp_image_url(image)
    polymorphic_url(practice_ogp_variant(image))
  end

  def practice_ogp_meta_tags(image_url)
    set_meta_tags(
      og: { image: image_url, url: request.url },
      twitter: { image: image_url, url: request.url }
    )
  end

  def difficulty_icon(minutes)
    return '' if minutes.nil?

    case minutes
    when ..300 then '🔥' # 5時間以下
    when ..600 then '🔥🔥' # 10時間以下
    when ..900 then '🔥🔥🔥' # 15時間以下
    when ..1200 then '🔥🔥🔥🔥' # 20時間以下
    else '🔥🔥🔥🔥🔥' # 20時間超
    end
  end
end

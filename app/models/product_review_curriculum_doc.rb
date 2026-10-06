# frozen_string_literal: true

# Reads a directly referenced curriculum Doc, never an arbitrary authenticated page.
class ProductReviewCurriculumDoc
  CONTENT_LIMIT = 20_000
  DOC_PATH = %r{\A/pages/(\d+|[a-z][a-z0-9_-]{0,199})/?\z}
  CANONICAL_ORIGIN = ['https', 'bootcamp.fjord.jp', 443].freeze

  def initialize(url)
    @url = url
  end

  def support?
    uri = URI.parse(@url)
    return false unless uri.is_a?(URI::HTTP) && uri.userinfo.nil? && DOC_PATH.match?(uri.path)

    origin = [uri.scheme, uri.host, uri.port]
    return true if origin == CANONICAL_ORIGIN

    app_uri = URI.parse(Rails.application.routes.url_helpers.root_url)
    origin == [app_uri.scheme, app_uri.host, app_uri.port]
  rescue URI::InvalidURIError, ArgumentError
    false
  end

  def read
    return unless support?

    identifier = DOC_PATH.match(URI.parse(@url).path)[1]
    attribute = identifier.match?(/\A\d+\z/) ? :id : :slug
    fields = Page.where(wip: false).where(attribute => identifier).pick(:title, :body)
    return { url: @url, status: 'unavailable', reason: '未確認: 参照された公開済みDocが見つかりません。' } unless fields

    { url: @url, status: 'fetched', content: format_doc(*fields) }
  end

  private

  def format_doc(title, body)
    truncation = '切り詰め: 先頭20000文字のみ。残りは未確認です。' if body.length > CONTENT_LIMIT
    <<~TEXT
      # Curriculum Doc
      - Title: #{title}
      - URL: #{@url}
      - 確認範囲: 公開済みDocの本文のみ。コメントやリンク先は取得していません。
      #{truncation}

      #{body.slice(0, CONTENT_LIMIT)}
    TEXT
  end
end

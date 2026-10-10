# frozen_string_literal: true

class Metadata
  FETCH_ERRORS = [
    ExternalContent::HttpClient::FetchError,
    ExternalContent::HttpClient::ResponseTooLarge,
    URI::InvalidURIError,
    Addressable::URI::InvalidURIError,
    SocketError,
    SystemCallError,
    IOError,
    Timeout::Error,
    OpenSSL::SSL::SSLError,
    Net::HTTPBadResponse,
    Encoding::InvalidByteSequenceError,
    Encoding::UndefinedConversionError
  ].freeze

  def initialize(url)
    @url = url
  end

  def fetch
    @uri = Addressable::URI.parse(@url)
    return unless @uri && @uri.userinfo.nil?

    @uri = @uri.normalize
    response = ExternalContent::HttpClient.get(@uri.to_s, max_body_bytes: 2.megabytes, request_timeout: 10)
    return fetch_youtube_oembed unless response.success?

    parse(html_document(response)) || fetch_youtube_oembed
  rescue *FETCH_ERRORS
    nil
  end

  private

  def html_document(response)
    body = response.body.to_s.b
    encoding = declared_encoding(response.content_type)
    return Nokogiri::HTML(body.force_encoding(encoding).encode(Encoding::UTF_8)) if encoding

    document = Nokogiri::HTML(body)
    utf8 = body.dup.force_encoding(Encoding::UTF_8)
    # Respect HTML charset declarations; unlabelled, valid UTF-8 should not become Latin-1.
    return document if document.meta_encoding || !utf8.valid_encoding?

    Nokogiri::HTML(utf8)
  end

  def declared_encoding(content_type)
    charset = content_type.to_s[/charset\s*=\s*["']?([^\s;"']+)/i, 1]
    Encoding.find(charset) if charset
  rescue ArgumentError
    nil
  end

  def parse(document)
    object = OpenGraphReader.parse(document)
    return unless object

    {
      title: object.og.title,
      description: object.og.description,
      images: object.og.image&.url,
      site_name: object.og.site_name || @uri.host,
      favicon: favicon(document),
      url: @url,
      site_url: site_url
    }
  end

  def site_url
    "#{@uri.scheme}://#{@uri.host}"
  end

  def favicon(document)
    favicon_path = document.at_css('link[rel="icon"], link[rel="shortcut icon"]')&.attr('href')
    return unless favicon_path

    absolute_regexp = URI::DEFAULT_PARSER.make_regexp

    # faviconはサイトによって絶対パス、相対パスと異なるため、どちらにも対応出来る実装にしている
    if absolute_regexp.match?(favicon_path)
      favicon_path
    else
      URI.join(@uri.to_s, favicon_path).to_s
    end
  end

  def youtube?
    @uri.host.in?(%w[www.youtube.com youtube.com youtu.be])
  end

  def fetch_youtube_oembed
    return unless youtube?

    uri = Addressable::URI.parse('https://www.youtube.com/oembed')
    uri.query_values = { url: @url, format: 'json' }
    response = ExternalContent::HttpClient.get(uri.normalize.to_s, max_body_bytes: 2.megabytes, request_timeout: 10)
    return unless response.success?

    body = JSON.parse(response.body.to_s.dup.force_encoding(Encoding::UTF_8))
    {
      title: body['title'],
      description: nil,
      images: body['thumbnail_url'],
      site_name: 'YouTube',
      favicon: 'https://www.youtube.com/s/desktop/5af4fee3/img/favicon.ico',
      url: @url,
      site_url: 'https://www.youtube.com'
    }
  rescue JSON::ParserError
    nil
  end
end

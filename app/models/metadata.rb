# frozen_string_literal: true

class Metadata
  NETWORK_ERRORS = [
    SocketError,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    Net::OpenTimeout,
    Net::ReadTimeout,
    OpenSSL::SSL::SSLError
  ].freeze

  def initialize(url)
    @url = url
    @uri = Addressable::URI.parse(url).normalize
  end

  def fetch
    http = Net::HTTP.new(@uri.host, @uri.inferred_port)
    if @uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    http.response_body_encoding = true

    header = { 'User-Agent' => 'Bootcamp-LinkCard (+https://github.com/fjordllc/bootcamp)' }
    response = http.request_get(@uri.request_uri, header)
    return fetch_youtube_oembed unless response.is_a?(Net::HTTPSuccess)

    parse(response.body) || fetch_youtube_oembed
  rescue *NETWORK_ERRORS
    nil
  end

  private

  def parse(html)
    OpenGraphReader.config.synthesize_full_image_url = true
    object = OpenGraphReader.parse(html, @url)
    return metadata_fallback(html) if object.nil?

    {
      title: object.og.title,
      description: object.og.description,
      images: object.og.image&.url,
      site_name: object.og.site_name || @uri.host,
      favicon: favicon(html),
      url: @url,
      site_url: site_url
    }
  end

  def site_url
    "#{@uri.scheme}://#{@uri.host}"
  end

  def favicon(html)
    doc = Nokogiri::HTML(html)
    favicon_path = doc.at_css('link[rel="icon"], link[rel="shortcut icon"]')&.attr('href')
    return unless favicon_path

    absolute_regexp = URI::DEFAULT_PARSER.make_regexp

    # faviconはサイトによって絶対パス、相対パスと異なるため、どちらにも対応出来る実装にしている
    if absolute_regexp.match?(favicon_path)
      favicon_path
    else
      URI.join(@url, favicon_path).to_s
    end
  end

  def youtube?
    @uri.host.in?(%w[www.youtube.com youtube.com youtu.be])
  end

  def fetch_youtube_oembed
    return unless youtube?

    uri = Addressable::URI.parse('https://www.youtube.com/oembed')
    uri.query_values = { url: @url, format: 'json' }
    response = Net::HTTP.get_response(uri.normalize)
    return unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    {
      title: body['title'],
      description: nil,
      images: body['thumbnail_url'],
      site_name: 'YouTube',
      favicon: 'https://www.youtube.com/s/desktop/5af4fee3/img/favicon.ico',
      url: @url,
      site_url: 'https://www.youtube.com'
    }
  rescue JSON::ParserError, *NETWORK_ERRORS
    nil
  end

  def metadata_fallback(html)
    doc = Nokogiri::HTML(html)
    metadata = {
      title: fallback_title(doc),
      description: fallback_description(doc),
      images: fallback_images(doc),
      site_name: fallback_site_name(doc) || @uri.host,
      favicon: favicon(html),
      url: @url,
      site_url: site_url
    }
    return nil if metadata[:title].blank?

    metadata
  end

  def fallback_title(doc)
    card_content(doc, 'title') || doc.at_css('title')&.text&.strip
  end

  def fallback_description(doc)
    card_content(doc, 'description') || doc.at_css('meta[name="description"]')&.[]('content')
  end

  def fallback_images(doc)
    image_path = card_content(doc, 'image') || doc.at_css('link[rel="image_src"]')&.[]('href')
    return nil if image_path.blank?

    URI.join(@url, image_path).to_s
  end

  def fallback_site_name(doc)
    card_content(doc, 'site_name') || doc.at_css('meta[name="application-name"]')&.[]('content')
  end

  def card_content(doc, type)
    doc.at_css("meta[property='og:#{type}']")&.[]('content').presence ||
      doc.at_css("meta[name='twitter:#{type}']")&.[]('content').presence
  end
end

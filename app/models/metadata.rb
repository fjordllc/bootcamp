# frozen_string_literal: true

class Metadata
  def initialize(url)
    @url = url
    @uri = Addressable::URI.parse(url).normalize
  end

  def fetch
    response = Net::HTTP.get_response(@uri)
    response.message == 'OK' ? parse(response.body) : nil
  end

  private

  def parse(html)
    object = OpenGraphReader.parse(html)
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

  def site_url
    "#{@uri.scheme}://#{@uri.host}"
  end

  def favicon(html)
    doc = Nokogiri::HTML(html)
    favicon_path = doc.at_css('link[rel="icon"], link[rel="shortcut icon"]')&.[]('href')
    return unless favicon_path

    absolute_regexp = URI::DEFAULT_PARSER.make_regexp

    # faviconはサイトによって絶対パス、相対パスと異なるため、どちらにも対応出来る実装にしている
    if absolute_regexp.match?(favicon_path)
      favicon_path
    else
      URI.join(@url, favicon_path).to_s
    end
  end

  def fallback_title(doc)
    card_content(doc, 'title') || doc.at_css('title')&.text&.strip
  end

  def fallback_description(doc)
    card_content(doc, 'description') || doc.at_css('meta[name="description"]')&.[]('content')
  end

  def fallback_images(doc)
    card_content(doc, 'image') || doc.at_css('link[rel="image_src"]')&.[]('href')
  end

  def fallback_site_name(doc)
    card_content(doc, 'site_name') || doc.at_css('meta[name="application-name"]')&.[]('content')
  end

  def card_content(doc, type)
    doc.at_css("meta[property='og:#{type}']")&.[]('content').presence ||
      doc.at_css("meta[name='twitter:#{type}']")&.[]('content').presence
  end
end

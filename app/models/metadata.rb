# frozen_string_literal: true

class Metadata
  def initialize(url)
    @url = url
  end

  def fetch_metadata
    response = Url::Client.request(@url)
    case response
    when Net::HTTPSuccess
      parse_metadata(response.body)
    else
      {}
    end
  end

  private

  def parse_metadata(body)
    ogp = LinkCard::Ogp.new(body)
    metadata_names = %i[site_name site_url favicon url title description image]
    metadata_names.map do |metadata_name|
      content = case metadata_name
                when :site_url then site_url
                when :favicon then favicon(body, site_url)
                else ogp.send(metadata_name)
                end
      [metadata_name, content]
    end.to_h
  end

  def site_url
    uri = Addressable::URI.parse(@url).normalize
    "#{uri.scheme}://#{uri.host}"
  end

  def favicon(body, site_url)
    doc = Nokogiri::HTML(body)
    favicon_path = doc.at_css('link[rel="icon"]')['href']
    absolute_regexp = URI::DEFAULT_PARSER.make_regexp

    # faviconはサイトによって絶対パス、相対パスと異なるため、どちらにも対応出来る実装にしている
    if absolute_regexp.match?(favicon_path)
      favicon_path
    else
      URI.join(site_url, favicon_path).to_s
    end
  end
end

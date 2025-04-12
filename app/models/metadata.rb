# frozen_string_literal: true

class Metadata
  def initialize(url)
    @url = url
  end

  def fetch
    response = Link::Client.request(@url)
    response.message == 'OK' ? parse(response.body) : nil
  end

  private

  def parse(html)
    og = OpenGraph.new(html)
    metadata_keys = %i[site_name site_url favicon url title description images]
    metadata_keys.map do |metadata_key|
      content = case metadata_key
                when :site_url then site_url
                when :favicon then favicon(site_url, html)
                when :site_name then og.metadata[:site_name][0][:_value]
                else og.public_send(metadata_key)
                end
      [metadata_key, content]
    end.to_h
  end

  def site_url
    uri = Addressable::URI.parse(@url).normalize
    "#{uri.scheme}://#{uri.host}"
  end

  def favicon(site_url, html)
    doc = Nokogiri::HTML(html)
    favicon_path = doc.at_css('link[rel="icon"]')['href']
    return '' if favicon_path.nil?

    absolute_regexp = URI::DEFAULT_PARSER.make_regexp

    # faviconはサイトによって絶対パス、相対パスと異なるため、どちらにも対応出来る実装にしている
    if absolute_regexp.match?(favicon_path)
      favicon_path
    else
      URI.join(site_url, favicon_path).to_s
    end
  end
end

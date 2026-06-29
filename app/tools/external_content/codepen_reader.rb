# frozen_string_literal: true

require 'uri'

class ExternalContent::CodepenReader
  CONTENT_LIMIT = 20_000

  def self.support?(uri)
    uri.is_a?(URI::HTTPS) && uri.host == 'codepen.io' && uri.path.match?(%r{\A/[^/]+/pen/[^/]+/?\z})
  end

  def self.fetch(url)
    new.fetch(url)
  end

  def fetch(url)
    uri = URI.parse(url.to_s)
    return 'CodePenの公開Pen URLだけ取得できます。' unless self.class.support?(uri)

    pen = fetch_raw_sources(uri)
    pen = fetch_pen_details(uri) if pen.blank?
    return ExternalContent::UNREADABLE_URL_MESSAGE if pen.blank?

    format_pen(uri.to_s, pen)
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  rescue StandardError => e
    Rails.logger.warn("[ExternalContent::CodepenReader] #{url} #{e.class}: #{e.message}")
    ExternalContent::UNREADABLE_URL_MESSAGE
  end

  private

  def fetch_raw_sources(uri)
    Rails.cache.fetch("external_content/codepen/raw_sources/#{Digest::SHA256.hexdigest(uri.to_s)}", expires_in: 10.minutes) do
      sources = raw_source_urls(uri).filter_map do |language, source_url|
        response = ExternalContent::HttpClient.get(source_url, headers: raw_source_request_headers(language))
        next unless response.success?
        next if response.body.to_s.include?('Pen Not Found or Not Available as a Resource')

        [language, response.body.to_s]
      end.to_h

      sources.presence
    end
  end

  def raw_source_urls(uri)
    normalized_url = uri.to_s.delete_suffix('/')
    {
      'html' => "#{normalized_url}.html",
      'css' => "#{normalized_url}.css",
      'js' => "#{normalized_url}.js"
    }
  end

  def fetch_pen_details(uri)
    Rails.cache.fetch("external_content/codepen/#{Digest::SHA256.hexdigest(uri.to_s)}", expires_in: 10.minutes) do
      response = ExternalContent::HttpClient.get(details_url(uri), headers: request_headers)
      response.success? ? JSON.parse(response.body) : nil
    end
  rescue JSON::ParserError
    nil
  end

  def details_url(uri)
    owner, slug = uri.path.match(%r{\A/([^/]+)/pen/([^/]+)/?\z}).captures
    "https://codepen.io/#{owner}/pen/details/#{slug}"
  end

  def format_pen(url, pen)
    <<~TEXT
      # CodePen
      - URL: #{url}
      - Title: #{pen['title'].presence || '(no title)'}
      - Author: #{author_name(pen)}

      ## HTML
      ```html
      #{limited(pen['html'])}
      ```

      ## CSS
      ```css
      #{limited(pen['css'])}
      ```

      ## JavaScript
      ```js
      #{limited(pen['js'])}
      ```
    TEXT
  end

  def limited(content)
    content.to_s.slice(0, CONTENT_LIMIT)
  end

  def author_name(pen)
    author = pen['user'] || pen['owner']
    return author if author.is_a?(String) && author.present?
    return author['username'] if author.is_a?(Hash) && author['username'].present?
    return author['name'] if author.is_a?(Hash) && author['name'].present?

    '(unknown)'
  end

  def request_headers
    { 'User-Agent' => 'fjord-bootcamp-pjord', 'Accept' => 'application/json' }
  end

  def raw_source_request_headers(language)
    content_type = {
      'html' => 'text/html',
      'css' => 'text/css',
      'js' => 'application/javascript'
    }.fetch(language)

    { 'User-Agent' => 'fjord-bootcamp-pjord', 'Accept' => "#{content_type}, text/plain, */*" }
  end
end

# frozen_string_literal: true

require 'stringio'
require 'uri'

class ExternalContent::WebPageReader
  CONTENT_LIMIT = 20_000
  IMAGE_SIZE_LIMIT = 10.megabytes

  def self.fetch(url)
    new.fetch(url)
  end

  def fetch(url)
    uri = URI.parse(url.to_s)
    return 'httpまたはhttpsのURLだけ取得できます。' unless uri.is_a?(URI::HTTP)

    response = fetch_response(uri)
    return ExternalContent::UNREADABLE_URL_MESSAGE unless response.success?

    return format_image(response) if image?(response)

    format_page(response.url, response.body)
  rescue URI::InvalidURIError
    'URLの形式が正しくありません。'
  rescue StandardError => e
    Rails.logger.warn("[ExternalContent::WebPageReader] #{url} #{e.class}: #{e.message}")
    ExternalContent::UNREADABLE_URL_MESSAGE
  end

  private

  def fetch_response(uri)
    Rails.cache.fetch("external_content/web_page/#{Digest::SHA256.hexdigest(uri.to_s)}", expires_in: 10.minutes) do
      ExternalContent::HttpClient.get(uri.to_s, headers: request_headers)
    end
  end

  def format_page(url, body)
    <<~TEXT
      # Web Page
      - URL: #{url}

      #{extract_text(body).slice(0, CONTENT_LIMIT)}
    TEXT
  end

  def format_image(response)
    return ExternalContent::UNREADABLE_URL_MESSAGE if response.body.to_s.bytesize > IMAGE_SIZE_LIMIT

    io = StringIO.new(response.body.to_s.b)
    io.binmode

    RubyLLM::Content.new(
      <<~TEXT,
        # Image
        - URL: #{response.url}
        - Content-Type: #{normalized_content_type(response)}

        この画像の内容を確認して、回答やレビューに必要な文脈として使ってください。
      TEXT
      [io]
    )
  end

  def extract_text(body)
    document = Nokogiri::HTML(body.to_s)
    document.css('script, style, noscript').remove
    node = document.at('body') || document
    node.xpath('.//text()').map { |text| text.text.squish }.reject(&:blank?).join(' ')
  end

  def image?(response)
    normalized_content_type(response).start_with?('image/')
  end

  def normalized_content_type(response)
    response.content_type.to_s.split(';').first.to_s.downcase
  end

  def request_headers
    { 'User-Agent' => 'fjord-bootcamp-pjord' }
  end
end

# frozen_string_literal: true

class ExternalContent::GithubRawFileFormatter
  CONTENT_LIMIT = ExternalContent::GithubReader::CONTENT_LIMIT

  def initialize(url:, body:)
    @url = url
    @body = body
  end

  def format
    <<~TEXT
      # GitHub File
      - URL: #{url}

      ```#{language_name}
      #{normalize_body(body).slice(0, CONTENT_LIMIT)}
      ```
    TEXT
  end

  private

  attr_reader :url, :body

  def normalize_body(body)
    body.to_s.dup.force_encoding(Encoding::UTF_8).scrub
  end

  def language_name
    extension = File.extname(URI.parse(url).path).delete_prefix('.')
    extension.presence || 'text'
  rescue URI::InvalidURIError
    'text'
  end
end

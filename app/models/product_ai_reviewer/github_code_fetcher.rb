# frozen_string_literal: true

require 'net/http'
require 'uri'

class ProductAiReviewer::GithubCodeFetcher
  LINKS_LIMIT = 3
  CONTENT_LIMIT = 20_000
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 5

  class << self
    def fetch(text)
      github_urls(text).filter_map do |url|
        raw_url = raw_github_url(url)
        next unless raw_url

        body = fetch_url(raw_url)
        next if body.blank?

        {
          url: url,
          language: language_name(url),
          body: body.slice(0, CONTENT_LIMIT)
        }
      rescue StandardError => e
        Rails.logger.warn("[ProductAiReviewer] GitHub link fetch failed: #{url} #{e.class}: #{e.message}")
        nil
      end
    end

    private

    def github_urls(text)
      text.to_s.scan(%r{https?://[^\s\])>"']+})
          .map { |url| url.delete_suffix('.') }
          .select { |url| github_code_url?(url) }
          .uniq
          .first(LINKS_LIMIT)
    end

    def github_code_url?(url)
      uri = URI.parse(url)
      return true if uri.host == 'raw.githubusercontent.com'

      uri.host == 'github.com' && uri.path.include?('/blob/')
    rescue URI::InvalidURIError
      false
    end

    def raw_github_url(url)
      uri = URI.parse(url)
      return url if uri.host == 'raw.githubusercontent.com'
      return unless uri.host == 'github.com'

      match = uri.path.match(%r{\A/([^/]+)/([^/]+)/blob/([^/]+)/(.+)\z})
      return unless match

      owner, repository, branch, path = match.captures
      "https://raw.githubusercontent.com/#{owner}/#{repository}/#{branch}/#{path}"
    end

    def fetch_url(url)
      Rails.cache.fetch("product_ai_reviewer/github_code/#{Digest::SHA256.hexdigest(url)}", expires_in: 10.minutes) do
        uri = URI.parse(url)
        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == 'https',
          open_timeout: OPEN_TIMEOUT,
          read_timeout: READ_TIMEOUT
        ) do |http|
          http.get(uri.request_uri, github_request_headers)
        end
        response.is_a?(Net::HTTPSuccess) ? response.body : nil
      end
    end

    def github_request_headers
      headers = { 'User-Agent' => 'fjord-bootcamp-pjord' }
      headers['Authorization'] = "Bearer #{github_token}" if github_token.present?
      headers
    end

    def github_token
      ENV['PJORD_GITHUB_TOKEN'].presence
    end

    def language_name(url)
      extension = File.extname(URI.parse(url).path).delete_prefix('.')
      extension.presence || 'text'
    rescue URI::InvalidURIError
      'text'
    end
  end
end

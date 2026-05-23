# frozen_string_literal: true

require 'net/http'
require 'uri'

class ExternalContent::HttpClient
  Response = Struct.new(:url, :code, :body, :content_type, keyword_init: true) do
    def success?
      code.to_i.between?(200, 299)
    end
  end

  MAX_REDIRECTS = 5
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 8

  def self.get(url, headers: {})
    new(headers:).get(url)
  end

  def initialize(headers: {})
    @headers = headers
  end

  def get(url)
    fetch(URI.parse(url.to_s), redirects_left: MAX_REDIRECTS, visited: [])
  end

  private

  attr_reader :headers

  def fetch(uri, redirects_left:, visited:)
    raise URI::InvalidURIError unless uri.is_a?(URI::HTTP)
    raise "too many redirects: #{uri}" if redirects_left.negative?
    raise "redirect loop: #{uri}" if visited.include?(uri.to_s)

    response = request(uri)
    if response.is_a?(Net::HTTPRedirection)
      location = response['location'].to_s
      raise "redirect without location: #{uri}" if location.blank?

      next_uri = URI.join(uri, location)
      return fetch(next_uri, redirects_left: redirects_left - 1, visited: visited + [uri.to_s])
    end

    Response.new(
      url: uri.to_s,
      code: response.code,
      body: response.body,
      content_type: response['content-type']
    )
  end

  def request(uri)
    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https',
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT
    ) do |http|
      http.get(uri.request_uri, headers)
    end
  end
end

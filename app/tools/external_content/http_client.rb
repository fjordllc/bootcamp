# frozen_string_literal: true

require 'net/http'
require 'ipaddr'
require 'socket'
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
  BLOCKED_NETWORKS = [
    '0.0.0.0/8',
    '10.0.0.0/8',
    '100.64.0.0/10',
    '127.0.0.0/8',
    '169.254.0.0/16',
    '172.16.0.0/12',
    '192.168.0.0/16',
    '224.0.0.0/4',
    '::/128',
    '::1/128',
    'fc00::/7',
    'fe80::/10',
    'ff00::/8'
  ].map { |network| IPAddr.new(network) }.freeze

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

    validate_public_endpoint!(uri)
    raise "too many redirects: #{uri}" if redirects_left.negative?
    raise "redirect loop: #{uri}" if visited.include?(uri.to_s)

    response = request(uri)
    if response.is_a?(Net::HTTPRedirection)
      location = response['location'].to_s
      raise "redirect without location: #{uri}" if location.blank?

      next_uri = URI.join(uri, location)
      validate_public_endpoint!(next_uri)
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

  def validate_public_endpoint!(uri)
    addresses = resolved_addresses(uri)
    raise "unresolvable host: #{uri}" if addresses.empty?
    raise "private endpoint is not allowed: #{uri}" if addresses.any? { |address| private_endpoint?(address) }
  end

  def resolved_addresses(uri)
    host = uri.host.to_s
    raise URI::InvalidURIError if host.blank?

    Addrinfo.getaddrinfo(host, nil, nil, :STREAM).map(&:ip_address).uniq
  end

  def private_endpoint?(address)
    ip_address = IPAddr.new(address)
    BLOCKED_NETWORKS.any? { |network| network.include?(ip_address) }
  end
end

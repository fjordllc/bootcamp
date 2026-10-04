# frozen_string_literal: true

require 'net/http'
require 'ipaddr'
require 'socket'
require 'uri'
require 'timeout'

class ExternalContent::HttpClient
  Response = Struct.new(:url, :code, :body, :content_type, keyword_init: true) do
    def success?
      code.to_i.between?(200, 299)
    end
  end

  class ResponseTooLarge < StandardError; end

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

  def self.get(url, headers: {}, max_body_bytes: nil, request_timeout: nil)
    new(headers:, max_body_bytes:, request_timeout:).get(url)
  end

  def initialize(headers: {}, max_body_bytes: nil, request_timeout: nil)
    @headers = headers
    @max_body_bytes = max_body_bytes
    @request_timeout = request_timeout
  end

  def get(url)
    Timeout.timeout(@request_timeout) do
      fetch(URI.parse(url.to_s), redirects_left: MAX_REDIRECTS, visited: [])
    end
  end

  private

  attr_reader :headers

  def fetch(uri, redirects_left:, visited:)
    raise URI::InvalidURIError unless uri.is_a?(URI::HTTP) && uri.userinfo.nil?

    address = validate_public_endpoint!(uri)
    raise "too many redirects: #{uri}" if redirects_left.negative?
    raise "redirect loop: #{uri}" if visited.include?(uri.to_s)

    response = request(uri, address)
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

  def request(uri, address)
    # Disable environment proxies so only the validated address is contacted.
    http = Net::HTTP.new(uri.hostname, uri.port, nil)
    http.ipaddr = address
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    http.max_retries = 0
    http.start do
      http.request(Net::HTTP::Get.new(uri.request_uri, headers)) do |response|
        body = +''.b
        response.read_body do |chunk|
          raise ResponseTooLarge if @max_body_bytes && body.bytesize + chunk.bytesize > @max_body_bytes

          body << chunk
        end
        response.body = body
        response
      end
    end
  end

  def validate_public_endpoint!(uri)
    addresses = resolved_addresses(uri)
    raise "unresolvable host: #{uri}" if addresses.empty?
    raise "private endpoint is not allowed: #{uri}" if addresses.any? { |address| private_endpoint?(address) }

    addresses.first
  end

  def resolved_addresses(uri)
    host = uri.hostname.to_s
    raise URI::InvalidURIError if host.blank?

    Addrinfo.getaddrinfo(host, nil, nil, :STREAM).map(&:ip_address).uniq
  end

  def private_endpoint?(address)
    ip_address = IPAddr.new(address)
    ip_address = ip_address.native if ip_address.ipv4_mapped?
    BLOCKED_NETWORKS.any? { |network| network.include?(ip_address) }
  end
end

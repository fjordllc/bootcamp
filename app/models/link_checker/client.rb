# frozen_string_literal: true

module LinkChecker
  class Client
    SSL_VERIFY_NONE_HOST = [
      'www.tablesgenerator.com' # 中間証明書を取得できず、SSLサーバー証明書の検証に失敗するため
    ].freeze

    def self.request(url)
      new(url).request
    end

    def initialize(url)
      @url = url
    end

    def request
      uri = Addressable::URI.parse(@url).normalize
      options = {}
      options[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE if SSL_VERIFY_NONE_HOST.include?(uri.host)
      response = OpenURI.open_uri(uri, **options)
      response.status.first.to_i
    rescue OpenURI::HTTPError => e
      e.io.status.first.to_i
    rescue StandardError => _e
      false
    end
  end
end

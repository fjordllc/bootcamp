# frozen_string_literal: true

require 'net/http'

module LinkChecker
  module Checker
    DENY_HOST = [
      'codepen.io',
      'www.amazon.co.jp' # アクセスを繰り返すとリンク切れ判定のレスポンスが返されるようになるため
    ].freeze

    module_function

    def check_broken_links(links)
      links_with_valid_url = links.select { |link| valid_url?(link.url) && !denied_host?(link.url) }
      links_with_response = check_response(links_with_valid_url)
      broken_links = links_with_response.select { |link| !link.response || link.response > 403 }

      summary(broken_links)
    end

    def valid_url?(url)
      uri = Addressable::URI.parse(url)
      uri.scheme && uri.host
    rescue Addressable::URI::InvalidURIError
      false
    end

    def denied_host?(url)
      uri = Addressable::URI.parse(url)
      DENY_HOST.include?(uri.host)
    end

    def check_response(links)
      locks = Queue.new
      5.times { locks.push :lock }

      links.each do |link|
        Thread.new do
          lock = locks.pop
          link.response = Client.request(link.url)
          locks.push lock
        end.join
      end

      links
    end

    def summary(broken_links)
      return if broken_links.empty?

      texts = ['リンク切れがありました。']
      texts << broken_links.sort.map(&:to_s)
      texts.join("\n")
    end
  end
end

# frozen_string_literal: true

require 'net/http'

module LinkChecker
  class Checker
    DENY_HOST = [
      'codepen.io',
      'www.amazon.co.jp' # アクセスを繰り返すとリンク切れ判定のレスポンスが返されるようになるため
    ].freeze

    class << self
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
    end

    def initialize(links = [])
      @links = links
      @is_checked = false
      @broken_links = []
      @locks = Queue.new
      5.times { @locks.push :lock }
    end

    def summary_of_broken_links
      check unless @is_checked

      return if @broken_links.empty?

      texts = ['リンク切れがありました。']
      @broken_links.map do |link|
        texts << "- <#{link.url} | #{link.title}> in: <#{link.source_url} | #{link.source_title}>"
      end

      texts.join("\n")
    end

    def check
      @links = @links.select { |link| self.class.valid_url?(link.url) && !self.class.denied_host?(link.url) }

      @links.map do |link|
        Thread.new do
          lock = @locks.pop
          response = Client.request(link.url)
          link.response = response
          @broken_links << link if !response || response > 403
          @locks.push lock
        end
      end.each(&:join)

      @is_checked = true
      @broken_links.sort { |a, b| b.source_url <=> a.source_url }
    end
  end
end

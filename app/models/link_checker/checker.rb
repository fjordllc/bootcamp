# frozen_string_literal: true

require 'net/http'

module LinkChecker
  class Checker
    DENY_HOST = %w[
      codepen.io
      www.amazon.co.jp
    ].freeze
    attr_reader :errors

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
      @errors = []
      @broken_links = []
      @locks = Queue.new
      5.times { @locks.push :lock }
    end

    def notify_broken_links
      check
      return if @broken_links.empty?

      texts = ['リンク切れがありました。']
      @broken_links.map do |link|
        texts << "- <#{link.url}|#{link.title}> in: <#{link.source_url}|#{link.source_title}>"
      end

      ChatNotifier.message(texts.join("\n"), username: 'リンクチェッカー')
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

      @broken_links.sort { |a, b| b.source_url <=> a.source_url }
    end
  end
end

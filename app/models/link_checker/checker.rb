# frozen_string_literal: true

require "net/http"

module LinkChecker
  class Checker
    DELAY = 10
    AMAZON_HOST = "www.amazon.co.jp"
    DENY_LIST = %w(
      codepen.io
    )
    attr_reader :errors

    def initialize
      @errors = []
      @error_links = []
    end

    def notify_missing_links
      check
      unless @error_links.empty?
        texts = ["リンク切れがありました。"]
        @error_links.map do |link|
          texts << "- <#{link.url}|#{link.title}> in: <#{link.source_url}|#{link.source_title}>"
        end

        SlackNotification.notify texts.join("\n"),
          channel: "bootcamp_notification",
          username: "リンクチェッカー"
      end
    end

    def check
      locks = Queue.new
      5.times { locks.push :lock }
      all_links.reject do |link|
        DENY_LIST.include?(URI.parse(link.url).host)
      end.map do |link|
        Thread.new do
          lock = locks.pop
          link.response = check_status(link.url)
          if !link.response
            @error_links << link
          end
          locks.push lock
        end
      end.each(&:join)

      @error_links.sort { |a, b| b.source_url <=> a.source_url }
    end

    def all_links
      page_links + practice_links
    end

    private
      def page_links
        links = []
        Page.order(:created_at).each do |page|
          extractor = Extractor.new(
            page.body,
            page.title,
            "https://bootcamp.fjord.jp" + Rails.application.routes.url_helpers.polymorphic_path(page)
          )
          links += extractor.extract
        end
        links
      end

      def practice_links
        links = []
        Practice.order(:created_at).each do |practice|
          practice_url = Rails.application.routes.url_helpers.polymorphic_path(practice)
          extractor = Extractor.new(
            practice.description,
            practice.title,
            "https://bootcamp.fjord.jp" + practice_url
          )
          links += extractor.extract

          extractor = Extractor.new(
            practice.goal,
            practice.title,
            "https://bootcamp.fjord.jp" + practice_url
          )
          links += extractor.extract
        end
        links
      end

      def check_status(url)
        begin
          url = URI.encode(url) # rubocop:disable Lint/UriEscapeUnescape
          uri = URI.parse(url)
        end

        return true if !uri
        return true if DENY_LIST.include?(uri.host)

        sleep DELAY if uri.host == AMAZON_HOST
        response = Net::HTTP.get_response(uri)
        response.code.to_i < 404
      rescue StandardError => _
        false
      end
  end
end

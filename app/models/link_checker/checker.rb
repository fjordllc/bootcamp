# frozen_string_literal: true

require 'net/http'

module LinkChecker
  class Checker
    DENY_LIST = %w[
      codepen.io
      www.amazon.co.jp
    ].freeze
    attr_reader :errors

    def initialize(links = [])
      @links = links
      @errors = []
      @error_links = []
    end

    def notify_missing_links
      check
      return if @error_links.empty?

      texts = ['リンク切れがありました。']
      @error_links.map do |link|
        texts << "- <#{link.url}|#{link.title}> in: <#{link.source_url}|#{link.source_title}>"
      end

      ChatNotifier.message(texts.join("\n"), username: 'リンクチェッカー')
    end

    def check
      locks = Queue.new
      5.times { locks.push :lock }
      @links.reject! do |link|
        url = URI.encode_www_form_component(link.url)
        uri = URI.parse(url)
        !uri || DENY_LIST.include?(uri.host)
      end

      @links.map do |link|
        Thread.new do
          lock = locks.pop
          response = Client.request(link.url)
          link.response = response
          @error_links << link if !response || response > 403
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
          "https://bootcamp.fjord.jp#{Rails.application.routes.url_helpers.polymorphic_path(page)}"
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
          "https://bootcamp.fjord.jp#{practice_url}"
        )
        links += extractor.extract

        extractor = Extractor.new(
          practice.goal,
          practice.title,
          "https://bootcamp.fjord.jp#{practice_url}"
        )
        links += extractor.extract
      end
      links
    end
  end
end

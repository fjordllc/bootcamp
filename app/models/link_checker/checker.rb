# frozen_string_literal: true

require "net/http"

module LinkChecker
  class Checker
    def self.start
      self.new.notify_missing_links
    end

    def notify_missing_links
      error_links = check
      unless error_links.empty?
        texts = ["リンク切れがありました。"]
        error_links.map do |link|
          texts << "- <#{link.url}|#{link.title}> in: <#{link.source_url}|#{link.source_title}>"
        end

        SlackNotification.notify texts.join("\n"),
          channel: "bootcamp_notification",
          username: "リンクチェッカー"
      end
    end

    def check
      threads = []
      error_links = []
      all_links.each do |link|
        threads << Thread.new do
          link.response = check_status(link.url)
          if !link.response
            error_links << link
          end
        end
      end
      threads.each(&:join)

      error_links.sort { |a, b| b.source_url <=> a.source_url }
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
        response = Net::HTTP.get_response(URI.parse(url))
        response.code.to_i < 402
      rescue StandardError => _
        false
      end
  end
end

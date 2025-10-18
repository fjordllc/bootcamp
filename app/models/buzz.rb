# frozen_string_literal: true

class Buzz < ApplicationRecord
  validates :title, presence: true
  validates :published_at, presence: true
  validates :url, presence: true, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message:
    'URLに誤りがあります'
  }

  require 'net/http'

  ALLOWED_SCHEMES = %w[http https].freeze

  class << self
    def for_year(year)
      start_date = start_of_year(year)
      end_date = end_of_year(year)
      Buzz.where('published_at >= ? AND published_at < ?', start_date, end_date)
    end

    def latest_year
      maximum('published_at')&.year
    end

    def years
      pluck('published_at').map { |date| date&.year }.uniq.sort.reverse
    end

    def doc_from_url(url)
      uri = URI.parse(url)
      raise ArgumentError, 'HTTP/HTTPS URLs only' unless %w[http https].include?(uri.scheme&.downcase)

      begin
        html = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: (uri.scheme == 'https'),
          open_timeout: 1,
          read_timeout: 5,
          write_timeout: 5
        ) do |http|
          http.get(uri).body
        end
      rescue StandardError => e
        logger.warn("#{url}: #{e.message}")
        return
      end
      Nokogiri::HTML.parse(html)
    end

    def title_from_doc(doc)
      doc.at_css('title')&.text
    end

    def date_from_doc(doc)
      date = doc.at_css('meta[property="article:published_time"]')&.[]('content')&.slice(0, 10)
      date ? Date.parse(date) : nil
    end

    private

    def start_of_year(year)
      Date.parse("#{year}-01-01")
    end

    def end_of_year(year)
      next_year = year.to_i + 1
      Date.parse("#{next_year}-01-01")
    end
  end
end

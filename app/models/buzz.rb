# frozen_string_literal: true

class Buzz < ApplicationRecord
  validates :title, presence: true
  validates :published_at, presence: true
  validates :url, presence: true, uniqueness: { message: 'はすでに登録されています' }
  validate :url_format

  require 'net/http'

  ALLOWED_SCHEMES = %w[http https].freeze

  def url_format
    return if url.blank?

    return if self.class.valid_scheme?(url)

    errors.add(:url, 'は"http://"か"https://"から始める必要があります')
  end

  class << self
    def for_year(year)
      start_date = start_of_year(year)
      end_date = start_of_next_year(year)
      Buzz.where('published_at >= ? AND published_at < ?', start_date, end_date)
    end

    def latest_year
      maximum('published_at')&.year
    end

    def years
      pluck('published_at').map { |date| date&.year }.uniq.sort.reverse
    end

    def doc_from_url(url)
      return nil unless valid_scheme?(url)

      uri = URI.parse(url)

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

    def valid_scheme?(url)
      uri = URI.parse(url)
      %w[http https].include?(uri.scheme&.downcase)
    end

    private

    def start_of_year(year)
      Date.parse("#{year}-01-01")
    end

    def start_of_next_year(year)
      next_year = year.to_i + 1
      Date.parse("#{next_year}-01-01")
    end
  end
end

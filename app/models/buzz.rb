# frozen_string_literal: true

class Buzz < ApplicationRecord
  # validates :body, presence: true
  validates :published_at, presence: true
  require 'open-uri'

  class << self
    def for_year(year)
      start_date = start_of_year(year)
      end_date = end_of_year(year)
      Buzz.where('published_at >= ? AND published_at < ?', start_date, end_date)
    end

    def latest_year
      muximum('published_at')&.year
    end

    def years
      pluck('published_on').map { |date| date&.year }.uniq.sort.reverse
    end

    def doc_from_url(url)
      Nokogiri::HTML(URI.parse(url))
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

# frozen_string_literal: true

require "open-uri"
require "nokogiri"

class GithubGrass
  SELECTOR = "svg.js-calendar-graph-svg"
  WDAYS = %w[日 月 火 水 木 金 土].freeze
  MONTHS = {
    Jan: "1", Feb: "2", Mar: "3", Apr: "4",
    May: "5", Jun: "6", Jul: "7", Aug: "8",
    Sep: "9", Oct: "10", Nov: "11", Dec: "12"
  }.freeze

  def initialize(name)
    @name = name
  end

  def fetch
    if Rails.env.test?
      ""
    else
      localize(extract_svg(fetch_page)).to_s
    end
  rescue
    ""
  end

  private

  def extract_svg(html)
    Nokogiri::HTML(html).css(SELECTOR)
  end

  def fetch_page
    URI.parse(github_url(@name)).open.read
  end

  def localize(svg)
    localize_month(localize_wday(svg)).to_s
  end

  def localize_wday(svg)
    svg.css("text.wday").map.with_index do |wday, i|
      wday[:style] = ""
      wday[:dy] = 12 + (15 * i)
      wday.children = WDAYS[i]
    end
    svg
  end

  def localize_month(svg)
    svg.css("text.month").map do |month|
      month.children = MONTHS[month.children.text.to_sym]
    end
    svg
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end

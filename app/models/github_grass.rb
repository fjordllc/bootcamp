# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

class GithubGrass
  SELECTOR = 'table.ContributionCalendar-grid.js-calendar-graph-table'
  SELECTOR_TO_REMOVE = 'tool-tip'

  WDAYS = {
    Sun: '日', Mon: '月', Tue: '火', Wed: '水',
    Thu: '木', Fri: '金', Sat: '土'
  }.freeze

  MONTHS = {
    Jan: '1', Feb: '2', Mar: '3', Apr: '4',
    May: '5', Jun: '6', Jul: '7', Aug: '8',
    Sep: '9', Oct: '10', Nov: '11', Dec: '12'
  }.freeze

  def initialize(name)
    @name = name
  end

  def fetch
    table = extract_table(fetch_page)
    localize(table).to_s
  rescue StandardError
    ''
  end

  private

  def extract_table(html)
    table = Nokogiri::HTML(html).css(SELECTOR)
    table.css(SELECTOR_TO_REMOVE).each(&:remove)
    table
  end

  def fetch_page
    uri = URI.parse(github_url(@name))
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def localize(table)
    table.css('span[aria-hidden="true"]').each do |label|
      localize_month(label)
      localize_wday(label)
    end
    table
  end

  def localize_wday(label)
    wdays_key = label.children.text.strip.to_sym
    return unless WDAYS[wdays_key]

    label.children = WDAYS[wdays_key]
    label[:class] = 'wdays'
  end

  def localize_month(label)
    months_key = label.children.text.to_sym
    return unless MONTHS[months_key]

    label.children = MONTHS[months_key]
    label[:class] = 'months'
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end

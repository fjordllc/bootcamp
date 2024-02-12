# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

class GithubGrass
  SELECTOR = 'table.js-calendar-graph-table'

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
    Nokogiri::HTML(html).css(SELECTOR)
  end

  def fetch_page
    uri = URI.parse(github_url(@name))
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def localize(table)
    table.css('span[aria-hidden="true"]').each do |label|
      text = label.children.to_s.strip.to_sym
      if WDAYS[text]
        label.children = WDAYS[text]
        label[:class] = 'wdays'
      elsif MONTHS[text]
        label.children = MONTHS[text]
        label[:class] = 'months'
      end
    end
    table
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end

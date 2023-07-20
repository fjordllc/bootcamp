# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

class GithubContribution
  TABLE_ROW_SELECTOR = '.ContributionCalendar-grid tbody tr'
  TABLE_DATA_SELECTOR = '.ContributionCalendar-day'

  def initialize(name)
    @name = name
  end

  def generate_table
    extract_contributions
      .map do |contribution_row|
        contribution_row.map { |contribution| contribution.attribute('data-level').value.to_i }
      end
  end

  private

  def extract_contributions
    rows = extract_contribution_rows(fetch_page)
    remove_contribution_label(rows)
  end

  def extract_contribution_rows(html)
    Nokogiri::HTML(html).css(TABLE_ROW_SELECTOR)
  end

  def remove_contribution_label(rows)
    rows.map { |row| row.css(TABLE_DATA_SELECTOR) }
  end

  def fetch_page
    uri = URI.parse(github_url(@name))
    response = Net::HTTP.get_response(uri)
    response.body
  rescue StandardError
    ''
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end

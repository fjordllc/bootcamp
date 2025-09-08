# frozen_string_literal: true

require 'test_helper'
require 'net/http'
require 'webmock'

class BuzzTest < ActiveSupport::TestCase
  test '.for_year returns buzzes within given year' do
    year = 2025
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year + 1, 1, 1)
    buzzes_for_year = Buzz.where('published_at >= ? AND published_at < ?', start_date, end_date)
    assert_equal buzzes_for_year, Buzz.for_year(year)
  end

  test '.latest_year' do
    Buzz.delete_all
    Buzz.create!(title: 'buzz1', url: 'https://www.example.com', published_at: '2023-01-01')
    Buzz.create!(title: 'buzz2', url: 'https://www.example.com', published_at: '2024-01-01')
    Buzz.create!(title: 'buzz3', url: 'https://www.example.com', published_at: '2025-01-01')
    latest_year = 2025
    assert_equal latest_year, Buzz.latest_year
  end

  test '.years' do
    Buzz.delete_all
    Buzz.create!(title: 'buzz1', url: 'https://www.example.com', published_at: '2024-01-01')
    Buzz.create!(title: 'buzz2', url: 'https://www.example.com', published_at: '2025-01-01')
    years = [2025, 2024]
    assert_equal years, Buzz.years
  end

  test '.doc_from_url returns nokogori object when succeeded' do
    dummy_response = <<~BODY
      <title>buzz1</title>
    BODY
    stub_request(:get, 'https://www.example.com')
      .to_return(status: 200, body: dummy_response)
    url = 'https://www.example.com'
    assert_instance_of Nokogiri::HTML::Document, Buzz.doc_from_url(url)
  end

  test '.doc_from_url returns nil when timeout' do
    stub_request(:get, 'https://www.example.com')
      .to_timeout
    url = 'https://www.example.com'
    assert_nil Buzz.doc_from_url(url)
  end

  test '.doc_from_url raises ArgumentError when given url scheme is not http or https' do
    url = 'ftp://www.example.com'
    assert_raises(ArgumentError) do
      Buzz.doc_from_url(url)
    end
  end

  test '.title_from_doc extract title when from title tag' do
    html = <<~BODY
      <title>buzz1</title>
    BODY
    doc = Nokogiri::HTML.parse(html)
    assert_equal 'buzz1', Buzz.title_from_doc(doc)
  end

  test '.title_from_doc returns nil when no title tag exists' do
    html = <<~BODY
      <nav>buzz1</nav>
    BODY
    doc = Nokogiri::HTML.parse(html)
    assert_nil Buzz.title_from_doc(doc)
  end

  test '.date_from_doc extract date from meta published_time tag' do
    html = <<~BODY
      <meta property="article:published_time" content="2025-08-06T02:21:55Z" />
    BODY
    doc = Nokogiri::HTML.parse(html)
    assert_equal Date.parse('2025-08-06'), Buzz.date_from_doc(doc)
  end

  test '.date_from_doc returns nil when no meta published_time tag exists' do
    html = <<~BODY
      <nav>2025-08-06</nav>
    BODY
    doc = Nokogiri::HTML.parse(html)
    assert_nil Buzz.date_from_doc(doc)
  end
end

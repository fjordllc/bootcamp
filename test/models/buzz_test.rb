# frozen_string_literal: true

require 'test_helper'
require 'supports/buzz_helper'

class BuzzTest < ActiveSupport::TestCase
  include BuzzHelper

  setup do
    Buzz.delete_all
  end

  test '.for_year returns buzzes within given year' do
    buzz1 = create_buzz('2023-12-31')
    buzz2 = create_buzz('2024-01-01')
    buzz3 = create_buzz('2024-12-31')
    buzz4 = create_buzz('2025-01-01')

    result = Buzz.for_year(2024)
    assert_not_includes result, buzz1
    assert_includes result, buzz2
    assert_includes result, buzz3
    assert_not_includes result, buzz4
  end

  test '.latest_year' do
    dates = %w[2023-01-01 2024-01-01 2025-01-01]
    create_buzzes(dates)
    latest_year = 2025
    assert_equal latest_year, Buzz.latest_year
  end

  test '.years' do
    dates = %w[2024-01-01 2025-01-01]
    create_buzzes(dates)
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

  test '.title_from_doc extracts title from title tag' do
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

  test '.date_from_doc extracts date from meta published_time tag' do
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

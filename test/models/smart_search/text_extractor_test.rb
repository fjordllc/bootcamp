# frozen_string_literal: true

require 'test_helper'

class SmartSearch::TextExtractorTest < ActiveSupport::TestCase
  test 'extracts text from Practice' do
    practice = practices(:practice1)
    text = SmartSearch::TextExtractor.extract(practice)

    assert_not_nil text
    assert_includes text, practice.title
  end

  test 'extracts text from Report' do
    report = reports(:report1)
    text = SmartSearch::TextExtractor.extract(report)

    assert_not_nil text
    assert_includes text, report.title
  end

  test 'extracts text from Page' do
    page = pages(:page1)
    text = SmartSearch::TextExtractor.extract(page)

    assert_not_nil text
    assert_includes text, page.title
  end

  test 'extracts text from Question' do
    question = questions(:question1)
    text = SmartSearch::TextExtractor.extract(question)

    assert_not_nil text
    assert_includes text, question.title
  end

  test 'extracts text from Announcement' do
    announcement = announcements(:announcement1)
    text = SmartSearch::TextExtractor.extract(announcement)

    assert_not_nil text
    assert_includes text, announcement.title
  end

  test 'extracts text from Comment' do
    comment = comments(:comment1)
    text = SmartSearch::TextExtractor.extract(comment)

    assert_not_nil text
  end

  test 'extracts text from Product' do
    product = products(:product1)
    text = SmartSearch::TextExtractor.extract(product)

    assert_not_nil text
  end

  test 'extracts text from Event' do
    event = events(:event1)
    text = SmartSearch::TextExtractor.extract(event)

    assert_not_nil text
    assert_includes text, event.title
  end

  test 'extracts text from Answer' do
    answer = answers(:answer1)
    text = SmartSearch::TextExtractor.extract(answer)

    assert_not_nil text
  end

  test 'returns nil for unknown model' do
    unknown_object = Object.new
    text = SmartSearch::TextExtractor.extract(unknown_object)

    assert_nil text
  end

  test 'truncates text to max length' do
    long_text = 'a' * (SmartSearch::Configuration::MAX_TEXT_LENGTH + 100)
    truncated = SmartSearch::TextExtractor.truncate_text(long_text)

    assert_equal SmartSearch::Configuration::MAX_TEXT_LENGTH, truncated.length
  end

  test 'does not truncate short text' do
    short_text = 'short text'
    result = SmartSearch::TextExtractor.truncate_text(short_text)

    assert_equal short_text, result
  end

  test 'returns nil for blank text' do
    assert_nil SmartSearch::TextExtractor.truncate_text(nil)
    assert_nil SmartSearch::TextExtractor.truncate_text('')
    assert_nil SmartSearch::TextExtractor.truncate_text('   ')
  end
end

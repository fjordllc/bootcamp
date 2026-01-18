# frozen_string_literal: true

require 'test_helper'

module SmartSearch
  class TextExtractorTest < ActiveSupport::TestCase
    test 'extracts text from Practice' do
      practice = practices(:practice1)
      text = TextExtractor.extract(practice)
      assert_includes text, practice.title
      assert_includes text, practice.description if practice.description.present?
    end

    test 'extracts text from Report' do
      report = reports(:report1)
      text = TextExtractor.extract(report)
      assert_includes text, report.title
    end

    test 'extracts text from Question' do
      question = questions(:question1)
      text = TextExtractor.extract(question)
      assert_includes text, question.title
    end

    test 'extracts text from Announcement' do
      announcement = announcements(:announcement1)
      text = TextExtractor.extract(announcement)
      assert_includes text, announcement.title
    end

    test 'extracts text from Page' do
      page = pages(:page1)
      text = TextExtractor.extract(page)
      assert_includes text, page.title
    end

    test 'extracts text from Comment' do
      comment = comments(:comment1)
      text = TextExtractor.extract(comment)
      assert_includes text, comment.description if comment.description.present?
    end

    test 'truncates long text' do
      long_text = 'a' * 10_000
      result = TextExtractor.truncate_text(long_text)
      assert_equal Configuration::MAX_TEXT_LENGTH, result.length
    end

    test 'returns nil for blank text' do
      assert_nil TextExtractor.truncate_text('')
      assert_nil TextExtractor.truncate_text(nil)
    end
  end
end

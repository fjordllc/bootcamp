# frozen_string_literal: true

require 'test_helper'

class TextbookTest < ActiveSupport::TestCase
  test '#published scope returns only published textbooks' do
    published = Textbook.published
    assert published.all?(&:published?)
    assert_not_includes published, textbooks(:textbook_draft)
  end

  test 'title is required' do
    textbook = Textbook.new(title: nil)
    assert_not textbook.valid?
    assert_includes textbook.errors[:title], 'を入力してください'
  end

  test '#chapters returns associated chapters' do
    textbook = textbooks(:textbook_ruby)
    assert_equal 2, textbook.chapters.size
  end

  test '#practice is optional' do
    textbook = textbooks(:textbook_git)
    assert_nil textbook.practice
    assert textbook.valid?
  end

  test 'destroying textbook destroys chapters' do
    textbook = textbooks(:textbook_ruby)
    assert_difference 'Textbook::Chapter.count', -textbook.chapters.count do
      textbook.destroy!
    end
  end
end

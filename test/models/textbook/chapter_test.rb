# frozen_string_literal: true

require 'test_helper'

class Textbook::ChapterTest < ActiveSupport::TestCase
  fixtures :textbooks, :textbook_chapters, :textbook_sections
  test 'title is required' do
    chapter = Textbook::Chapter.new(title: nil, textbook: textbooks(:textbook_ruby), position: 0)
    assert_not chapter.valid?
    assert_includes chapter.errors[:title], 'を入力してください'
  end

  test 'position is required' do
    chapter = Textbook::Chapter.new(title: 'Test', textbook: textbooks(:textbook_ruby), position: nil)
    assert_not chapter.valid?
    assert_includes chapter.errors[:position], 'を入力してください'
  end

  test '#sections returns associated sections' do
    chapter = textbook_chapters(:chapter_ruby_basics)
    assert_equal 2, chapter.sections.size
  end

  test 'default scope orders by position' do
    textbook = textbooks(:textbook_ruby)
    chapters = textbook.chapters
    assert_equal chapters.map(&:position), chapters.map(&:position).sort
  end

  test 'destroying chapter destroys sections' do
    chapter = textbook_chapters(:chapter_ruby_basics)
    assert_difference 'Textbook::Section.count', -chapter.sections.count do
      chapter.destroy!
    end
  end
end

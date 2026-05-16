# frozen_string_literal: true

require 'test_helper'

class Textbook::SectionTest < ActiveSupport::TestCase
  fixtures :textbooks, :textbook_chapters, :textbook_sections, :reading_progresses, :term_explanations, :users
  test 'title is required' do
    section = Textbook::Section.new(
      title: nil,
      body: 'content',
      chapter: textbook_chapters(:chapter_ruby_basics),
      position: 0
    )
    assert_not section.valid?
    assert_includes section.errors[:title], 'を入力してください'
  end

  test 'body is required' do
    section = Textbook::Section.new(
      title: 'Test',
      body: nil,
      chapter: textbook_chapters(:chapter_ruby_basics),
      position: 0
    )
    assert_not section.valid?
    assert_includes section.errors[:body], 'を入力してください'
  end

  test 'position is required' do
    section = Textbook::Section.new(
      title: 'Test',
      body: 'content',
      chapter: textbook_chapters(:chapter_ruby_basics),
      position: nil
    )
    assert_not section.valid?
    assert_includes section.errors[:position], 'を入力してください'
  end

  test 'default scope orders by position' do
    chapter = textbook_chapters(:chapter_ruby_basics)
    Textbook::Section.create!(title: 'Z Last', body: 'content', chapter: chapter, position: 99)
    Textbook::Section.create!(title: 'A First', body: 'content', chapter: chapter, position: 0)
    sections = chapter.sections.reload
    positions = sections.map(&:position)
    assert_equal positions.sort, positions
  end

  test '#reading_progresses returns associated progresses' do
    section = textbook_sections(:section_variables)
    assert_includes section.reading_progresses, reading_progresses(:reading_progress_komagata_variables)
  end

  test '#term_explanations returns associated explanations' do
    section = textbook_sections(:section_variables)
    assert_includes section.term_explanations, term_explanations(:term_variable)
  end

  test 'goals and key_terms are arrays' do
    section = textbook_sections(:section_variables)
    assert_kind_of Array, section.goals
    assert_kind_of Array, section.key_terms
  end
end

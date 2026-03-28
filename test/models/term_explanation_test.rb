# frozen_string_literal: true

require 'test_helper'

class TermExplanationTest < ActiveSupport::TestCase
  def setup
    @textbook = Textbook.create!(title: 'Test Textbook', description: 'Test Description')
    @chapter = @textbook.chapters.create!(title: 'Test Chapter', position: 0)
    @section = @chapter.sections.create!(title: 'Test Section', body: 'Test content', position: 0, estimated_minutes: 10)
  end

  test 'term is required' do
    explanation = TermExplanation.new(
      section: @section,
      term: nil,
      explanation: 'test'
    )
    assert_not explanation.valid?
    assert_includes explanation.errors[:term], 'を入力してください'
  end

  test 'explanation is required' do
    explanation = TermExplanation.new(
      section: @section,
      term: 'test_term',
      explanation: nil
    )
    assert_not explanation.valid?
    assert_includes explanation.errors[:explanation], 'を入力してください'
  end

  test 'term must be unique per section' do
    existing = TermExplanation.create!(
      section: @section,
      term: 'test_term',
      explanation: 'original explanation'
    )

    duplicate = TermExplanation.new(
      section: existing.section,
      term: existing.term,
      explanation: 'different explanation'
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:term], 'はすでに存在します'
  end

  test 'same term can exist in different sections' do
    other_section = @chapter.sections.create!(
      title: 'Other Section',
      body: 'Other content',
      position: 1,
      estimated_minutes: 5
    )

    TermExplanation.create!(
      section: @section,
      term: 'shared_term',
      explanation: 'explanation in first section'
    )

    explanation = TermExplanation.new(
      section: other_section,
      term: 'shared_term',
      explanation: 'explanation in second section'
    )
    assert explanation.valid?
  end
end

# frozen_string_literal: true

require 'test_helper'

class ReadingProgressTest < ActiveSupport::TestCase
  def setup
    @user = users(:komagata)
    @textbook = Textbook.create!(title: 'Test Textbook', description: 'Test Description')
    @chapter = @textbook.chapters.create!(title: 'Test Chapter', position: 0)
    @section = @chapter.sections.create!(title: 'Test Section', body: 'Test content', position: 0, estimated_minutes: 10)
  end

  test 'user and section combination must be unique' do
    # Create existing record
    existing = ReadingProgress.create!(
      user: @user,
      section: @section,
      read_ratio: 0.5
    )

    duplicate = ReadingProgress.new(
      user: existing.user,
      section: existing.section,
      read_ratio: 0.0
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], 'はすでに存在します'
  end

  test 'read_ratio must be between 0.0 and 1.0' do
    progress = ReadingProgress.new(user: @user, section: @section, read_ratio: 0.5)

    progress.read_ratio = -0.1
    assert_not progress.valid?

    progress.read_ratio = 1.1
    assert_not progress.valid?

    progress.read_ratio = 0.5
    assert progress.valid?
  end

  test '#complete! sets completed and read_ratio' do
    progress = ReadingProgress.create!(user: @user, section: @section, read_ratio: 0.3)
    progress.complete!
    progress.reload

    assert progress.completed?
    assert_equal 1.0, progress.read_ratio
    assert_not_nil progress.last_read_at
  end
end

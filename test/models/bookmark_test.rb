# frozen_string_literal: true

require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test 'prohibition of duplicate registration' do
    user = users(:machida)
    report = reports(:report1)

    Bookmark.create(user:, bookmarkable: report)
    assert_not Bookmark.new(user:, bookmarkable: report).valid?
  end

  test 'prohibit to duplicate question registration' do
    user = users(:kimura)
    question = questions(:question1)

    Bookmark.create(user:, bookmarkable: question)
    assert_not Bookmark.new(user:, bookmarkable: question).valid?
  end

  test 'prohibit to duplicate product registration' do
    user = users(:kimura)
    product = products(:product1)

    Bookmark.create(user:, bookmarkable: product)
    assert_not Bookmark.new(user:, bookmarkable: product).valid?
  end

  test 'prohibit to duplicate page registration' do
    user = users(:kimura)
    page = pages(:page1)

    Bookmark.create(user:, bookmarkable: page)
    assert_not Bookmark.new(user:, bookmarkable: page).valid?
  end

  test 'prohibit to duplicate talk registration' do
    user = users(:komagata)
    talk = talks(:talk1)

    Bookmark.create(user:, bookmarkable: talk)
    assert_not Bookmark.new(user:, bookmarkable: talk).valid?
  end
end

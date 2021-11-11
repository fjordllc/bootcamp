# frozen_string_literal: true

require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test 'prohibition of duplicate registration' do
    user = users(:machida)
    report = reports(:report1)

    Bookmark.create(user: user, bookmarkable: report)
    assert_not Bookmark.new(user: user, bookmarkable: report).valid?
  end

  test 'prohibit to duplicate question registration' do
    user = users(:kimura)
    question = questions(:question1)

    Bookmark.create(user: user, bookmarkable: question)
    assert_not Bookmark.new(user: user, bookmarkable: question).valid?
  end

  test 'prohibit to duplicate product registration' do
    user = users(:kimura)
    product = products(:product1)

    Bookmark.create(user: user, bookmarkable: product)
    assert_not Bookmark.new(user: user, bookmarkable: product).valid?
  end

  test 'prohibit to duplicate page registration' do
    user = users(:kimura)
    page = pages(:page1)

    Bookmark.create(user: user, bookmarkable: page)
    assert_not Bookmark.new(user: user, bookmarkable: page).valid?
  end
end

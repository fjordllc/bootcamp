# frozen_string_literal: true

require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test '.bookmarkable_class resolves supported exact type names' do
    types = %w[Announcement Page Talk Movie RegularEvent Event Product Question Report]
    models = [Announcement, Page, Talk, Movie, RegularEvent, Event, Product, Question, Report]

    types.zip(models).each do |type, model|
      assert_same model, Bookmark.bookmarkable_class(type)
    end
  end

  test '.bookmarkable_class rejects unsupported names and non-string values' do
    ['User', 'Kernel', 'Object', 'UnknownResource', 'Inquiry', 'CorporateTrainingInquiry', 'PairWork', '', ' ',
     'report', '::Report', 'Report ', Report, nil, {}, [], :Report, true, false, 123].each do |type|
      assert_nil Bookmark.bookmarkable_class(type), "Expected #{type.inspect} to be rejected"
    end
  end

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

# frozen_string_literal: true

require 'test_helper'

class CommentableTest < ActiveSupport::TestCase
  # Announcement, Event, Page, Product, RegularEvent, Report, Talk にincludeされている
  test 'commentable_notification_title for Announcement' do
    announcement = announcements(:announcement1)
    expected = 'お知らせ「お知らせ1」'
    assert_equal expected, announcement.commentable_notification_title
  end

  test 'commentable_notification_title for Event' do
    event = events(:event1)
    expected = '特別イベント「ミートアップ」'
    assert_equal expected, event.commentable_notification_title
  end

  test 'commentable_notification_title for Page' do
    page = pages(:page1)
    expected = 'Docs「test1」'
    assert_equal expected, page.commentable_notification_title
  end

  test 'commentable_notification_title for Product' do
    product = products(:product1)
    expected = 'mentormentaroさんの「OS X Mountain Lionをクリーンインストールする」の提出物'
    assert_equal expected, product.commentable_notification_title
  end

  test 'commentable_notification_title for RegularEvent' do
    regular_event = regular_events(:regular_event1)
    expected = '定期イベント「開発MTG」'
    assert_equal expected, regular_event.commentable_notification_title
  end

  test 'commentable_notification_title for Report' do
    report = reports(:report1)
    expected = 'komagataさんの日報「作業週1日目」'
    assert_equal expected, report.commentable_notification_title
  end

  test 'commentable_notification_title for Talk' do
    talk = talks(:talk1)
    expected = 'komagataさんの相談部屋'
    assert_equal expected, talk.commentable_notification_title
  end
end

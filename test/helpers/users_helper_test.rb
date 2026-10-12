# frozen_string_literal: true

require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test 'user_activity_count uses prepared counts including zero without loading associations' do
    user = Minitest::Mock.new
    user.expect(:id, 123)
    user.expect(:id, 123)
    user.expect(:id, 123)
    user.expect(:id, 123)
    counts = { 123 => { reports: 7, comments: 0 } }

    assert_equal 7, user_activity_count(user, :reports, counts)
    assert_equal 0, user_activity_count(user, :comments, counts)
    user.verify
  end

  test 'user_activity_count falls back to association counts when prepared counts are unavailable' do
    user = users(:kimura)
    expected = user.reports.count

    assert_equal expected, user_activity_count(user, :reports)
    assert_equal expected, user_activity_count(user, :reports, {})
  end

  test 'user_activity_count excludes private comments in its fallback' do
    user = users(:komagata)
    public_comments = user.comments.where.not(commentable_type: %w[Talk Inquiry CorporateTrainingInquiry]).count
    assert_operator user.comments.count, :>, public_comments

    assert_equal public_comments, user_activity_count(user, :comments)
    assert_equal public_comments, user_activity_count(user, :comments, {})
  end

  test 'user_card_following_options distinguishes unavailable data from an unfollowed user' do
    user = users(:kimura)

    assert_empty user_card_following_options(user)
    assert_equal({ is_following: false, is_watching: false }, user_card_following_options(user, {}))
  end

  test 'user_card_following_options preserves watching and nonwatching followings' do
    user = users(:kimura)
    [true, false].each do |watching|
      following = Following.new(watch: watching)

      assert_equal({ is_following: true, is_watching: watching }, user_card_following_options(user, user.id => following))
    end
  end

  test 'user_card_progress returns no overrides when prepared counts are unavailable' do
    user = users(:kimura)

    assert_empty user_card_progress(user)
    assert_empty user_card_progress(user, {})
  end

  test 'user_card_progress computes prepared progress and prefers existing cached values' do
    user = users(:kimura)
    counts = { user.id => { completed: 5, completed_required: 3, required: 8 } }
    cache = ActiveSupport::Cache::MemoryStore.new

    Rails.stub(:cache, cache) do
      assert_equal({ percentage: 37.5, fraction: '修了: 5 （必須: 3/8）' }, user_card_progress(user, counts))

      cache.write("/model/user_course_practice/#{user.id}/completed_percentage", 12.5)
      cache.write("/model/user_course_practice/#{user.id}/completed_fraction", 'Cached progress fraction')

      assert_equal({ percentage: 12.5, fraction: 'Cached progress fraction' }, user_card_progress(user, counts))
    end
  end

  test 'user_course_practice_percentage computes and reuses the decorator cache key' do
    user = users(:kimura)
    counts = { completed_required: 3, required: 8 }
    cache = ActiveSupport::Cache::MemoryStore.new
    key = "/model/user_course_practice/#{user.id}/completed_percentage"

    Rails.stub(:cache, cache) do
      assert_equal 37.5, user_course_practice_percentage(user, counts)
      assert_equal 37.5, cache.read(key)
      assert_equal 37.5, user_course_practice_percentage(user, completed_required: 8, required: 8)

      cache.write(key, 0)
      assert_equal 0, user_course_practice_percentage(user, counts)
    end
  end

  test 'all_countries_with_subdivisions' do
    countries = JSON.parse(all_countries_with_subdivisions)
    assert_includes countries['JP'], %w[北海道 01]
    assert_includes countries['US'], %w[アラスカ州 AK]
  end

  test '#roles_for_select' do
    user_roles = [
      %w[全員 all],
      %w[現役生 student_and_trainee],
      %w[非アクティブ inactive],
      %w[休会 hibernated],
      %w[退会 retired],
      %w[卒業 graduate],
      %w[アドバイザー adviser],
      %w[メンター mentor],
      %w[研修生 trainee],
      %w[忘年会 year_end_party],
      %w[お試し延長 campaign]
    ]
    assert roles_for_select, user_roles
  end

  test '#jobs_for_select' do
    user_jobs = [
      %w[全員 all],
      %w[学生 student],
      %w[会社員 office_worker],
      %w[フリーター part_time_worker],
      %w[休職中 vacation],
      %w[働いていない unemployed]
    ]
    assert jobs_for_select, user_jobs
  end
end

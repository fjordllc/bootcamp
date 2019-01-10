# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin?" do
    assert users(:komagata).admin?
    assert users(:machida).admin?
  end

  test "full_name" do
    assert_equal "Komagata Masaki", users(:komagata).full_name
  end

  test "active?" do
    travel_to Time.new(2014, 1, 1, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.new(2014, 2, 2, 0, 0, 0) do
      assert_not users(:machida).active?
    end
  end

  test "twitter_account" do
    Bootcamp::Setup.attachment

    user = users(:komagata)
    user.twitter_account = ""
    assert user.valid?
    user.twitter_account = "azAZ_09"
    assert user.valid?
    user.twitter_account = "-"
    assert user.invalid?
    user.twitter_account = "あ"
    assert user.invalid?
    user.twitter_account = ":"
    assert user.invalid?
    user.twitter_account = "A" * 16
    assert user.invalid?
  end

  test "returns true when product of designated practice is checked" do
    assert users(:tanaka).has_checked_product_of?(practices(:practice_2))
  end

  test "returns false when product of designated practice isn't checked" do
    assert_not users(:tanaka).has_checked_product_of?(practices(:practice_3))
  end

  test "returns false when no product of designated practice" do
    assert_not users(:tanaka).has_checked_product_of?(practices(:practice_4))
  end

  test "total_learnig_time" do
    user = users(:hatsuno)
    assert_equal 0, user.total_learning_time

    report = Report.new(user_id: user.id, title: "test", reported_on: "2018-01-01", description: "test", wip: false)
    report.learning_times << LearningTime.new(started_at: "2018-01-01 00:00:00", finished_at: "2018-01-01 02:00:00")
    report.save!
    assert_equal 2, user.total_learning_time
  end

  test "elapsed_days" do
    user = users(:komagata)
    user.created_at = Time.new(2019, 1, 1, 0, 0, 0)
    travel_to Time.new(2020, 1, 1, 0, 0, 0) do
      assert_equal 365, user.elapsed_days
    end
  end

  test "order_by_counts" do
    names = User.order_by_counts("report", "desc").pluck(:login_name)
    assert_equal ["tanaka", "komagata", "yamada", "machida", "kimura", "muryou", "yameo", "mineo", "hajime", "hatsuno", "kensyu"], names

    names = User.order_by_counts("comment", "asc").pluck(:login_name)
    assert_equal ["yameo", "hajime", "hatsuno", "kensyu", "kimura", "muryou", "yamada", "mineo", "machida", "tanaka", "komagata"], names
  end

  test "invalid when blank to retire_reason column" do
    user = users(:hatsuno)
    assert user.retire_reason.blank?
    assert_not user.save(context: :retire_reason_presence)
  end

  test "valid when more than 8 characters to retire_reason column" do
    user = users(:hatsuno)
    user.retire_reason = "辞" * 8
    assert user.save(context: :retire_reason_presence)
  end
end

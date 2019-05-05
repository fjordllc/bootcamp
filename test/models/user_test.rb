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
    expected = %w(sotugyou komagata machida yamada advijirou yameo kimura hatsuno hajime muryou kensyu)
    assert_equal expected, names

    names = User.order_by_counts("comment", "asc").pluck(:login_name)
    expected = %w(advijirou yameo yamada kimura hatsuno hajime muryou kensyu machida sotugyou komagata)
    assert_equal expected, names
  end

  test "when retire_reason is blank" do
    user = users(:hatsuno)
    assert user.retire_reason.blank?
    assert_not user.save(context: :retire_reason_presence)
  end

  test "is valid with 8 or more characters" do
    Bootcamp::Setup.attachment
    user = users(:hatsuno)
    user.retire_reason = "辞" * 8
    assert user.save(context: :retire_reason_presence)
  end
end

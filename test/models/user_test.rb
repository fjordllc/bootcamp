# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin?" do
    assert users(:komagata).admin?
    assert users(:machida).admin?
  end

  test "retired?" do
    assert users(:yameo).retired?
    assert_not users(:komagata).retired?
  end

  test "full_name" do
    assert_equal "Komagata Masaki", users(:komagata).full_name
  end

  test "kana_full_name" do
    assert_equal "コマガタ マサキ", users(:komagata).kana_full_name
  end

  test "is valid kana_last_name" do
    Bootcamp::Setup.attachment

    user = users(:komagata)
    user.kana_last_name = "コマガタ"
    assert user.valid?
    user.kana_last_name = "駒形"
    assert user.invalid?
    user.kana_last_name = "こまがた"
    assert user.invalid?
    user.kana_last_name = "komagata"
    assert user.invalid?
    user.kana_last_name = "-"
    assert user.invalid?
    user.kana_last_name = ""
    assert user.invalid?
  end

  test "is valid kana_first_name" do
    Bootcamp::Setup.attachment

    user = users(:komagata)
    user.kana_first_name = "マサキ"
    assert user.valid?
    user.kana_first_name = "真幸"
    assert user.invalid?
    user.kana_first_name = "まさき"
    assert user.invalid?
    user.kana_first_name = "masaki"
    assert user.invalid?
    user.kana_first_name = "-"
    assert user.invalid?
    user.kana_first_name = ""
    assert user.invalid?
  end

  test "active?" do
    travel_to Time.new(2014, 1, 1, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.new(2014, 2, 2, 0, 0, 0) do
      assert_not users(:machida).active?
    end
  end

  test "prefecture_name" do
    assert_equal "未登録", users(:komagata).prefecture_name
    assert_equal "東京都", users(:kimura).prefecture_name
    assert_equal "宮城県", users(:hatsuno).prefecture_name
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
    report.learning_times << LearningTime.new(started_at: "2018-01-01 23:00:00", finished_at: "2018-01-02 01:00:00")
    report.save!
    assert_equal 4, user.total_learning_time
  end

  test "elapsed_days" do
    user = users(:komagata)
    user.created_at = Time.new(2019, 1, 1, 0, 0, 0)
    travel_to Time.new(2020, 1, 1, 0, 0, 0) do
      assert_equal 365, user.elapsed_days
    end
  end

  test "order_by_counts" do
    ordered_users = User.order_by_counts("report", "desc")
    more_report_user = users(:sotugyou)
    less_report_user = users(:yamada)
    assert ordered_users.index(more_report_user) < ordered_users.index(less_report_user)

    ordered_users = User.order_by_counts("comment", "asc")
    more_comment_user = users(:komagata)
    less_comment_user = users(:sotugyou)
    assert ordered_users.index(less_comment_user) < ordered_users.index(more_comment_user)
  end

  test "is valid with 8 or more characters" do
    Bootcamp::Setup.attachment
    user = users(:hatsuno)
    user.retire_reason = "辞" * 8
    assert user.save(context: :retire_reason_presence)
  end

  test "avatar_url" do
    user = users(:kimura)
    assert_equal "/images/users/default.png", user.avatar_url
  end
end

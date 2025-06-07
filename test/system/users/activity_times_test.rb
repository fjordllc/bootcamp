# frozen_string_literal: true

require 'application_system_test_case'

class Users::ActivityTimesTest < ApplicationSystemTestCase
  setup do
    # kimuraの活動時間を設定: 日曜日の21時と月曜日の10時
    kimura = users(:kimura)
    sunday_twenty_one = learning_time_frames(:sun21)
    monday_ten = learning_time_frames(:mon10)

    LearningTimeFramesUser.create!(user: kimura, learning_time_frame: sunday_twenty_one)
    LearningTimeFramesUser.create!(user: kimura, learning_time_frame: monday_ten)

    # hatsunoの活動時間を設定: 火曜日の15時
    hatsuno = users(:hatsuno)
    tuesday_fifteen = learning_time_frames(:tue15)

    LearningTimeFramesUser.create!(user: hatsuno, learning_time_frame: tuesday_fifteen)
  end

  test 'show users by activity time on sunday twenty one' do
    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'

    assert_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end

  test 'show users by activity time on monday ten' do
    visit_with_auth '/users/activity_times?day_of_week=1&hour=10', 'kimura'

    assert_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end

  test 'show users by activity time on tuesday fifteen' do
    visit_with_auth '/users/activity_times?day_of_week=2&hour=15', 'kimura'

    assert_text 'Hatsuno Shinji'
    assert_no_text 'Kimura Tadasi'
  end

  test 'show no users when no one is active at that time' do
    visit_with_auth '/users/activity_times?day_of_week=3&hour=5', 'kimura'

    assert_no_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end

  test 'show users with current time as default' do
    travel_to Time.zone.local(2024, 1, 7, 21, 0, 0) do
      visit_with_auth '/users/activity_times', 'kimura'

      assert_text 'Kimura Tadasi'
      assert_no_text 'Hatsuno Shinji'
    end
  end

  test 'show different users when changing time parameters' do
    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'
    assert_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'

    # パラメータを変更して火曜日の15時にアクセス
    visit '/users/activity_times?day_of_week=2&hour=15'
    assert_text 'Hatsuno Shinji'
    assert_no_text 'Kimura Tadasi'
  end

  test 'admin, mentor, student, and trainee users are included in results' do
    # 管理者・メンター・受講生・研修生の活動時間を設定
    komagata = users(:komagata) # 管理者・メンター
    kensyu = users(:kensyu)     # 研修生
    users(:kimura) # 受講生
    sunday_twenty_one = learning_time_frames(:sun21)
    LearningTimeFramesUser.create!(user: komagata, learning_time_frame: sunday_twenty_one)
    LearningTimeFramesUser.create!(user: kensyu, learning_time_frame: sunday_twenty_one)

    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'

    # すべて表示される
    assert_text 'Kimura Tadasi'
    assert_text 'Kensyu Seiko'
    assert_text 'Komagata Masaki'
  end

  test 'graduated and retired users are excluded from results' do
    # 卒業生の活動時間を設定してみる
    sotugyou = users(:sotugyou)
    sunday_twenty_one = learning_time_frames(:sun21)
    LearningTimeFramesUser.create!(user: sotugyou, learning_time_frame: sunday_twenty_one)

    # 退会者の活動時間を設定してみる
    yameo = users(:yameo)
    LearningTimeFramesUser.create!(user: yameo, learning_time_frame: sunday_twenty_one)

    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'

    # kimuraは受講生なので表示される
    assert_text 'Kimura Tadasi'
    # 卒業生・退会者は表示されない
    assert_no_text '卒業 太郎'
    assert_no_text '辞目 辞目夫'
  end

  test 'trainee users are included in results' do
    # 研修生の活動時間を設定
    kensyu = users(:kensyu)
    sunday_twenty_one = learning_time_frames(:sun21)
    LearningTimeFramesUser.create!(user: kensyu, learning_time_frame: sunday_twenty_one)

    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'

    # kimura（受講生）とkensyu（研修生）の両方が表示される
    assert_text 'Kimura Tadasi'
    assert_text 'Kensyu Seiko'
  end

  test 'invalid day_of_week parameter shows no users' do
    visit_with_auth '/users/activity_times?day_of_week=7&hour=21', 'kimura'

    assert_no_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end

  test 'invalid hour parameter shows no users' do
    visit_with_auth '/users/activity_times?day_of_week=0&hour=25', 'kimura'

    assert_no_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end
end

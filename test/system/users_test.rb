# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'show last active date and time of access user only to mentors' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      visit_with_auth login_path, 'kimura'
    end

    travel_to Time.zone.local(2014, 1, 1, 1, 0, 0) do
      visit login_path
    end

    travel_to Time.zone.local(2014, 1, 1, 2, 0, 0) do
      visit logout_path
    end

    visit_with_auth "/users/#{users(:kimura).id}", 'komagata'
    assert_text '最終活動日時'
    assert_text '2014年01月01日(水) 01:00'

    visit_with_auth "/users/#{users(:kimura).id}", 'hatsuno'
    assert_text 'kimura'
    assert_no_text '最終活動日時'

    visit_with_auth "/users/#{users(:neverlogin).id}", 'komagata'
    assert_text '最終活動日時'
    assert_no_text '2022年07月11日(月) 09:00'

    visit_with_auth "/users/#{users(:neverlogin).id}", 'hatsuno'
    assert_text 'neverlogin'
    assert_no_text '最終活動日時'
  end

  test 'show inactive message on users page' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      visit_with_auth '/', 'kimura'
    end

    visit_with_auth '/users', 'komagata'
    assert_no_selector 'div.users-item.inactive'
    assert_text '1ヶ月以上ログインがありません'

    visit_with_auth '/users', 'hatsuno'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_selector 'div.users-item.inactive'
    assert_no_text '1ヶ月以上ログインがありません'
  end

  test 'show inactive users only to mentors' do
    User.inactive_students_and_trainees.each do |user|
      user.update_columns(last_activity_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    end

    visit_with_auth '/', 'komagata'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text '1ヶ月以上ログインのないユーザー'

    users(:kimura).update!(
      last_activity_at: Time.zone.local(2020, 1, 1, 0, 0, 0)
    )

    visit_with_auth '/', 'komagata'
    assert_text '1ヶ月以上ログインのないユーザー'

    visit_with_auth '/', 'hatsuno'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text '1ヶ月以上ログインのないユーザー'
  end

  test 'push question tab for showing all the recoreded questions' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    click_link '質問'
    assert_text '質問のタブの作り方'
    assert_text '質問のタブに関して。。。追加質問'
  end

  test 'show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'

    visit practice_path(practices(:practice1).id)
    click_button '着手'
    assert_selector '.is-started.is-active'

    visit '/'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ようこそ'
  end

  test 'paging niconico_calendar' do
    visit_with_auth root_path, 'hatsuno'
    today = Date.current
    last_month = today.prev_month
    visit user_path(users(:hajime).id)
    assert_text "#{today.year}年#{today.month}月"
    find('.niconico-calendar-nav__previous').click
    assert_text "#{last_month.year}年#{last_month.month}月"
  end

  test 'show mark to today on niconico_calendar' do
    today = Date.current
    visit_with_auth root_path, 'hatsuno'
    visit user_path(users(:hajime).id)
    assert_selector '.niconico-calendar__day.is-today'
    target_day = find('.niconico-calendar__day.is-today').text
    assert_equal today.day.to_s, target_day
  end

  test 'not show mark to today on niconico_calendar' do
    visit_with_auth root_path, 'hatsuno'
    visit user_path(users(:hajime).id)
    find('.niconico-calendar-nav__previous').click
    assert_text 'hajime'
    assert_no_selector '.niconico-calendar__day.is-today'
  end

  test 'push guraduation button in user page when admin logined' do
    user = users(:kimura)
    visit_with_auth "/users/#{user.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
  end

  test 'learning time frames hidden after user graduation' do
    user = users(:kimura)
    LearningTimeFramesUser.create!(user:, learning_time_frame_id: 1)

    visit_with_auth "/users/#{user.id}", 'komagata'
    accept_confirm do
      click_link '卒業にする'
    end
    assert_text '卒業済'
    assert_no_selector 'label.a-form-label', text: '活動時間'
  end

  test 'GET /users/new' do
    visit '/users/new'
    assert_equal 'FBC参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as an adviser' do
    visit '/users/new?role=adviser'
    assert_equal 'FBCアドバイザー参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as a trainee' do
    visit '/users/new?role=trainee_invoice_payment'
    assert_equal 'FBC研修生参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /users/new as a mentor' do
    visit '/users/new?role=mentor'
    assert_equal 'FBCメンター参加登録 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'delete user' do
    user = users(:kimura)
    visit_with_auth "users/#{user.id}", 'komagata'
    click_link "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.name} さんを削除しました。"
  end
end

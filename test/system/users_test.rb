# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'show profile' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'autolink profile when url is included' do
    url = 'https://bootcamp.fjord.jp/'
    visit_with_auth edit_current_user_path, 'kimura'
    fill_in 'user_description', with: "木村です。ブートキャンプはじめました。#{url}"
    click_button '更新する'
    assert_link url, href: url
  end

  test 'access by other users' do
    user = users(:hatsuno)
    visit_with_auth edit_admin_user_path(user.id), 'mentormentaro'
    assert_text '管理者としてログインしてください'
  end

  test 'graduation date is displayed' do
    visit_with_auth "/users/#{users(:mentormentaro).id}", 'komagata'
    assert_no_text '卒業日'

    visit "/users/#{users(:sotugyou).id}"
    assert_text '卒業日'
  end

  test 'retired date is displayed' do
    visit_with_auth "/users/#{users(:yameo).id}", 'komagata'
    assert_text '退会日'
    visit "/users/#{users(:sotugyou).id}"
    assert_no_text '退会日'
  end

  test 'retire reason is displayed when login user is admin' do
    visit_with_auth "/users/#{users(:yameo).id}", 'komagata'
    assert_text '退会理由'
    visit "/users/#{users(:sotugyou).id}"
    assert_no_text '退会理由'
  end

  test "retire reason isn't displayed when login user isn't admin" do
    visit_with_auth "/users/#{users(:yameo).id}", 'kimura'
    assert_no_text '退会理由'
  end

  test "normal user can't see unchecked number table" do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    assert_equal 0, all('.admin-table').length
  end

  test 'show users role' do
    visit_with_auth "/users/#{users(:komagata).id}", 'komagata'
    assert_text '管理者'

    visit_with_auth "/users/#{users(:mentormentaro).id}", 'mentormentaro'
    assert_text 'メンター'

    visit_with_auth "/users/#{users(:advijirou).id}", 'advijirou'
    assert_text 'アドバイザー'

    visit_with_auth "/users/#{users(:kensyu).id}", 'kensyu'
    assert_text '研修生'

    visit_with_auth "/users/#{users(:sotugyou).id}", 'sotugyou'
    assert_text '卒業生'
  end

  test 'show completed practices' do
    visit_with_auth "/users/#{users(:kimura).id}", 'machida'
    assert_text 'OS X Mountain Lionをクリーンインストールする'
    assert_no_text 'Terminalの基礎を覚える'
  end

  test 'show last active date only to mentors' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      visit_with_auth '/', 'kimura'
    end

    visit_with_auth "/users/#{users(:kimura).id}", 'komagata'
    assert_text '最終ログイン'

    visit_with_auth "/users/#{users(:kimura).id}", 'hatsuno'
    assert_no_text '最終ログイン'
  end

  test 'show inactive message on users page' do
    travel_to Time.zone.local(2014, 1, 1, 0, 0, 0) do
      visit_with_auth '/', 'kimura'
    end

    visit_with_auth '/users', 'komagata'
    assert_no_selector 'div.users-item.inactive'
    assert_text '1ヶ月以上ログインがありません'

    visit_with_auth '/users', 'hatsuno'
    assert_no_selector 'div.users-item.inactive'
    assert_no_text '1ヶ月以上ログインがありません'
  end

  test 'show inactive users only to mentors' do
    %i[
      kimura
      hatsuno
      hajime
      muryou
      kensyu
      kananashi
      osnashi
      jobseeker
      daimyo
      nippounashi
      with_hyphen
    ].each do |name|
      users(name).touch # rubocop:disable Rails/SkipsModelValidations
    end

    visit_with_auth '/', 'komagata'
    assert_no_text '1ヶ月以上ログインのないユーザー'

    users(:kimura).update!(
      updated_at: Time.zone.local(2020, 1, 1, 0, 0, 0)
    )

    visit_with_auth '/', 'komagata'
    assert_text '1ヶ月以上ログインのないユーザー'

    visit_with_auth '/', 'hatsuno'
    assert_no_text '1ヶ月以上ログインのないユーザー'
  end

  test 'student access control' do
    visit_with_auth '/users', 'kimura'
    assert_no_text '全員'
    assert_no_text '就職活動中'

    visit 'users?target=retired'
    assert_no_text '退会'
  end

  test 'advisor access control' do
    visit_with_auth '/users', 'advijirou'
    assert_no_text '全員'
    assert find_link('就職活動中')

    visit 'users?target=retired'
    assert_no_text '退会'
  end

  test 'mentor access control' do
    visit_with_auth '/users', 'mentormentaro'
    assert find_link('就職活動中')
    assert find_link('全員')
  end

  test 'admin access control' do
    visit_with_auth '/users', 'komagata'
    assert find_link('就職活動中')
    assert find_link('全員')
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
    visit_with_auth practice_path(practices(:practice1).id), 'hatsuno'
    click_button '着手'
    wait_for_vuejs
    visit '/'
    assert_no_text 'ようこそ'
  end

  test 'paging niconico_calendar' do
    visit_with_auth root_path, 'hatsuno'
    today = Time.current
    last_month = today.prev_month
    visit user_path(users(:hajime).id)
    within '.niconico-calendar-nav' do
      assert_text "#{today.year}年#{today.month}月"
      find('.niconico-calendar-nav__previous').click
      wait_for_vuejs
      assert_text "#{last_month.year}年#{last_month.month}月"
    end
  end

  test 'show mark to today on niconico_calendar' do
    today = Time.current
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
    wait_for_vuejs
    assert_no_selector '.niconico-calendar__day.is-today'
  end

  test 'show times link on user page' do
    kimura = users(:kimura)

    visit_with_auth "/users/#{kimura.id}", 'hatsuno'
    assert_no_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')

    kimura.update!(times_url: 'https://discord.com/channels/715806612824260640/123456789000000007')

    visit current_path
    assert_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')
  end

  test 'show times link on user list page' do
    visit_with_auth '/users', 'hatsuno'
    assert_no_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')

    kimura = users(:kimura)
    kimura.update!(times_url: 'https://discord.com/channels/715806612824260640/123456789000000007')

    visit current_path
    assert_link(href: 'https://discord.com/channels/715806612824260640/123456789000000007')
  end

  test 'only admin can see link to talk on user list page' do
    visit_with_auth '/users', 'komagata'
    assert_link '相談部屋'
  end

  test 'not admin cannot see link to talk on user list page' do
    visit_with_auth '/users', 'kimura'
    assert_no_link '相談部屋'
  end

  test 'show daily report download button' do
    visit_with_auth "/users/#{users(:kimura).id}", 'komagata'
    assert_text '日報一括ダウンロード'
  end

  test 'not show daily report download button' do
    visit_with_auth "/users/#{users(:kimura).id}", 'hatsuno'
    assert_no_text '日報一括ダウンロード'
  end
end

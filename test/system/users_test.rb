# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  test 'show listing all users' do
    visit_with_auth users_path, 'kimura'
    assert_equal '全てのユーザー | FBC', title
    assert_selector 'h2.page-header__title', text: 'ユーザー'
  end

  test 'show profile' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    assert_equal 'hatsunoさんのプロフィール | FBC', title
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
    assert_text 'mentormentaro'
    assert_no_text '卒業日'

    visit "/users/#{users(:sotugyou).id}"
    assert_text '卒業日'
  end

  test 'retired date is displayed' do
    visit_with_auth "/users/#{users(:yameo).id}", 'komagata'
    assert_text '退会日'
    visit "/users/#{users(:sotugyou).id}"
    assert_text 'sotugyou'
    assert_no_text '退会日'
  end

  test 'retire reason is displayed when login user is admin' do
    visit_with_auth "/users/#{users(:yameo).id}", 'komagata'
    assert_text '退会理由'
    visit "/users/#{users(:sotugyou).id}"
    assert_text 'sotugyou'
    assert_no_text '退会理由'
  end

  test "retire reason isn't displayed when login user isn't admin" do
    visit_with_auth "/users/#{users(:yameo).id}", 'kimura'
    assert_text 'yameo'
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

    visit_with_auth "/users/#{users(:kyuukai).id}", 'kyuukai'
    assert_text '休会中'
  end

  test 'show completed practices' do
    visit_with_auth "/users/#{users(:kimura).id}", 'machida'
    assert_text 'OS X Mountain Lionをクリーンインストールする'
    assert_no_text 'Terminalの基礎を覚える'
  end

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

  test 'student access control' do
    visit_with_auth '/users', 'kimura'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_text '全員'
    assert_no_text '就職活動中'

    visit 'users?target=retired'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_text '退会'
  end

  test 'advisor access control' do
    visit_with_auth '/users', 'advijirou'
    assert_no_text '全員'
    assert find_link('就職活動中')

    visit 'users?target=retired'
    assert_selector '.page-header__title', text: 'ユーザー'
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
    assert find_link('退会')
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

  test 'only admin can see link to talk on user list page' do
    visit_with_auth '/users', 'komagata'
    assert_link '相談部屋'
  end

  test 'not admin cannot see link to talk on user list page' do
    visit_with_auth '/users', 'kimura'
    assert_selector '.page-header__title', text: 'ユーザー'
    assert_no_link '相談部屋'
  end

  test 'show daily report download button' do
    visit_with_auth "/users/#{users(:kimura).id}", 'komagata'
    assert_text '日報ダウンロード'
  end

  test 'not show daily report download button' do
    visit_with_auth "/users/#{users(:kimura).id}", 'hatsuno'
    assert_no_text '日報ダウンロード'
  end

  test 'show link to talk room when logined as admin' do
    kimura = users(:kimura)
    visit_with_auth "/users/#{kimura.id}", 'komagata'
    assert_text 'プロフィール'
    assert_link '相談部屋', href: "/talks/#{kimura.talk.id}"
  end

  test 'should not show link to talk room of admin even if logined as admin' do
    machida = users(:machida)
    visit_with_auth "/users/#{machida.id}", 'komagata'
    assert_text 'プロフィール'
    assert_no_link '相談部屋'
  end

  test 'should not show link to talk room when logined as no-admin' do
    hatsuno = users(:hatsuno)
    visit_with_auth "/users/#{hatsuno.id}", 'kimura'
    assert_text 'プロフィール'
    assert_no_link '相談部屋'
  end

  test 'show trainees for adviser' do
    visit_with_auth "/users/#{users(:kensyu).id}", 'senpai'
    assert_text '自社研修生'
    assert_no_text 'フォローする'
    assert_no_text '登録情報変更'
  end

  test 'show students' do
    visit_with_auth "/users/#{users(:kensyu).id}", 'hatsuno'
    assert_no_text '自社研修生'
    assert_text 'フォローする'
    assert_no_text '登録情報変更'
  end

  test 'show no trainees for adviser' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'senpai'
    assert_no_text '自社研修生'
    assert_text 'フォローする'
    assert_no_text '登録情報変更'
  end

  test 'show myself' do
    visit_with_auth "/users/#{users(:kensyu).id}", 'kensyu'
    assert_no_text '自社研修生'
    assert_no_text 'フォローする'
    assert_text '登録情報変更'
  end

  test 'show users trainees for adviser' do
    visit_with_auth '/users?target=trainee', 'senpai'
    assert_text '自社研修生'
  end

  test 'not show grass hide button for graduates' do
    visit_with_auth "/users/#{users(:sotugyou).id}", 'sotugyou'
    assert_text 'sotugyou'
    assert_not has_button? '非表示'
  end

  test 'show training end date if user is a trainee and has a training end date' do
    user = users(:kensyu)
    visit_with_auth user_path(user.id), 'kensyu'
    assert has_text?('研修終了日')
    assert has_text?('2022年04月01日')
  end

  test 'does not display training end date if user is a trainee and not has a training end date' do
    user = users(:kensyu)
    training_ends_on = nil
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    fill_in 'user_training_ends_on', with: training_ends_on
    click_on '更新する'
    visit_with_auth user_path(user.id), 'kensyu'
    assert_text 'kensyu'
    assert has_no_field?('user_training_ends_on')
  end

  test 'if the number of days it took to graduate is positive, the value is displayed.' do
    user = users(:sotugyou)
    user.update!(created_at: Time.zone.today - 1, graduated_on: Time.zone.today, job: 'office_worker')
    visit_with_auth "/users/#{user.id}", 'sotugyou'
    assert_text '卒業 1日'
  end

  test 'if the number of days it took to graduate is negative, the value is not displayed.' do
    user = users(:sotugyou)
    user.update!(created_at: Time.zone.today, graduated_on: Time.zone.today - 1, job: 'office_worker')
    visit_with_auth "/users/#{user.id}", 'sotugyou'
    assert_text 'sotugyou'
    assert_no_text '卒業 1日'
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

  test 'can upload heic image and converts it to webp with login_name' do
    skip 'HEICのサポートがないため、CI では実行されません。' if ENV['CI']

    visit_with_auth '/current_user/edit', 'hajime'
    attach_file 'user[avatar]', 'test/fixtures/files/images/heic-sample-file.heic', make_visible: true
    click_button '更新する'

    assert_text 'ユーザー情報を更新しました。'
    img = find('img.user-profile__user-icon-image', visible: false)
    assert_includes img.native['src'], 'hajime.webp'
  end

  test 'mentor can see retired and hibernated tabs' do
    visit_with_auth '/users', 'mentormentaro'
    assert_link '休会', href: '/users?target=hibernated'
    assert_link '退会', href: '/users?target=retired'
  end

  test 'admin can see retired and hibernated tabs' do
    visit_with_auth '/users', 'komagata'
    assert_link '休会', href: '/users?target=hibernated'
    assert_link '退会', href: '/users?target=retired'
  end

  test 'user can not see retired and hibernated tabs if the user is not admin or mentor' do
    visit_with_auth '/users', 'sotugyou'
    assert_no_link '休会', href: '/users?target=hibernated'
    assert_no_link '退会', href: '/users?target=retired'
  end

  test 'delete user' do
    user = users(:kimura)
    visit_with_auth "users/#{user.id}", 'komagata'
    click_link "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.name} さんを削除しました。"
  end

  test "should show students and trainees's active activity counts" do
    visit_with_auth users_path, 'kimura'
    assert_selector '.card-counts__item-value', text: '0'

    click_link('卒業生')
    assert_selector '.card-counts__item-value', text: '0'

    click_link('研修生')
    assert_selector '.card-counts__item-value', text: '0'
  end

  test "should show hibernated user and retired user's activity counts" do
    visit_with_auth users_path, 'komagata'
    click_link('休会')
    assert_selector '.card-counts__item-value', text: '0'

    click_link('退会')
    assert_selector '.card-counts__item-value', text: '0'
  end

  test "should not show mentor and adviser's activity counts" do
    visit_with_auth users_path, 'kimura'
    click_link('メンター')
    assert_no_selector '.card-counts__items'

    click_link('アドバイザー')
    assert_no_selector '.card-counts__items'
  end

  test 'show hibernation period in profile' do
    hibernated_user = users(:kyuukai)
    user = users(:hatsuno)

    travel_to hibernated_user.hibernated_at + 30.days do
      visit_with_auth user_path(hibernated_user), 'komagata'
      assert_text '休会中（休会から30日目）'
    end
    visit_with_auth user_path(user), 'komagata'
    assert_no_text '休会中（休会から'
  end

  test 'show retirement message on users page' do
    visit_with_auth users_path, 'komagata'
    click_link('退会')
    assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message', text: '退会しました'
  end

  test 'show hibernation elasped days message on users page' do
    travel_to Time.zone.local(2020, 1, 11, 0, 0, 0) do
      visit_with_auth users_path, 'komagata'
      click_link('休会')
      assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message', text: '休会中: 2020年01月01日〜(10日経過)'
    end
  end

  test 'students and trainees filter' do
    visit_with_auth '/users', 'komagata'
    click_link '現役 + 研修生'

    assert_selector('a.tab-nav__item-link.is-active', text: '現役 + 研修生')
    filtered_users = all('.users-item__icon .a-user-role')
    assert(filtered_users.all? do |user|
      classes = user[:class].split(' ')
      classes.include?('is-student') || classes.include?('is-trainee')
    end)
  end

  test 'students filter' do
    visit_with_auth '/users', 'komagata'
    click_link '現役生'

    assert_selector('a.tab-nav__item-link.is-active', text: '現役生')
    filtered_users = all('.users-item__icon .a-user-role')
    assert(filtered_users.all? { |user| user[:class].split(' ').include?('is-student') })
  end

  test 'can not upload broken image as user avatar' do
    visit_with_auth '/current_user/edit', 'hajime'
    attach_file 'user[avatar]', 'test/fixtures/files/images/broken_image.jpg', make_visible: true
    click_button '更新する'

    assert_text 'ユーザーアイコンは指定された拡張子(PNG, JPG, JPEG, GIF, HEIC, HEIF形式)になっていないか、あるいは画像が破損している可能性があります'
  end

  test 'visible learning time frames table on profile pages non advisors and grad users' do
    hatsuno = users(:hatsuno)
    mentormentaro = users(:mentormentaro)
    kensyu = users(:kensyu)

    LearningTimeFramesUser.create!(user: hatsuno, learning_time_frame_id: 1)
    LearningTimeFramesUser.create!(user: mentormentaro, learning_time_frame_id: 2)
    LearningTimeFramesUser.create!(user: kensyu, learning_time_frame_id: 3)

    visit_with_auth "/users/#{hatsuno.id}", 'kimura'
    assert_selector 'h1.page-main-header__title', text: 'プロフィール'
    assert_selector 'h2.card-header__title', text: '主な活動予定時間'

    visit_with_auth "/users/#{mentormentaro.id}", 'kimura'
    assert_selector 'h1.page-main-header__title', text: 'プロフィール'
    assert_selector 'h2.card-header__title', text: '主な活動予定時間'

    visit_with_auth "/users/#{kensyu.id}", 'kimura'
    assert_selector 'h1.page-main-header__title', text: 'プロフィール'
    assert_selector 'h2.card-header__title', text: '主な活動予定時間'
  end
end

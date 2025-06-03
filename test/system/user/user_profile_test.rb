# frozen_string_literal: true

require 'application_system_test_case'

class UserProfileTest < ApplicationSystemTestCase
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

  test 'push question tab for showing all the recoreded questions' do
    visit_with_auth "/users/#{users(:hatsuno).id}", 'hatsuno'
    click_link '質問'
    assert_text '質問のタブの作り方'
    assert_text '質問のタブに関して。。。追加質問'
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

  test 'can upload heic image as user avatar' do
    skip 'HEICのサポートがないため、CI では実行されません。' if ENV['CI']

    visit_with_auth '/current_user/edit', 'hajime'
    attach_file 'user[avatar]', 'test/fixtures/files/images/heic-sample-file.heic', make_visible: true
    click_button '更新する'

    assert_text 'ユーザー情報を更新しました。'
    img = find('img.user-profile__user-icon-image', visible: false)
    assert_match(/heic-sample-file\.png$/, img.native['src'])
  end

  test 'can not upload broken image as user avatar' do
    visit_with_auth '/current_user/edit', 'hajime'
    attach_file 'user[avatar]', 'test/fixtures/files/images/broken_image.jpg', make_visible: true
    click_button '更新する'

    assert_text 'ユーザーアイコンは指定された拡張子(PNG, JPG, JPEG, GIF, HEIC, HEIF形式)になっていないか、あるいは画像が破損している可能性があります'
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

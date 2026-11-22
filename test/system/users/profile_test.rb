# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class ProfileTest < ApplicationSystemTestCase
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

    test 'show completed practices' do
      visit_with_auth "/users/#{users(:kimura).id}", 'machida'
      assert_text 'OS X Mountain Lionをクリーンインストールする'
      assert_no_text 'Terminalの基礎を覚える'
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

    test 'show hibernating user history to admins and mentors' do
      hibernated_user = users(:kyuukai)

      visit_with_auth user_path(hibernated_user), 'komagata'
      assert_selector '.card-header__title', text: '休会履歴（1回）'
      assert_selector '.user-metas__title', text: '現在1回目の休会中'

      visit_with_auth user_path(hibernated_user), 'mentormentaro'
      assert_selector '.card-header__title', text: '休会履歴（1回）'
      assert_selector '.user-metas__title', text: '現在1回目の休会中'
    end

    test 'show previously hibernating user history to admins and mentors' do
      returned_user = users(:hukki)

      visit_with_auth user_path(returned_user), 'komagata'
      assert_selector '.card-header__title', text: '休会履歴（1回）'
      assert_selector '.user-metas__title', text: '1回目の休会'

      visit_with_auth user_path(returned_user), 'mentormentaro'
      assert_selector '.card-header__title', text: '休会履歴（1回）'
      assert_selector '.user-metas__title', text: '1回目の休会'
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

    test 'can upload heic image and converts it to webp with login_name' do
      visit_with_auth '/current_user/edit', 'hajime'
      attach_file 'user[avatar]', 'test/fixtures/files/images/heic-sample-file.heic', make_visible: true
      click_button '更新する'

      assert_text 'ユーザー情報を更新しました。'
      img = find('img.user-profile__user-icon-image', visible: false)
      assert_includes img.native['src'], 'hajime.webp'
    end

    test 'can not upload broken image as user avatar' do
      visit_with_auth '/current_user/edit', 'hajime'
      attach_file 'user[avatar]', 'test/fixtures/files/images/broken_image.jpg', make_visible: true
      click_button '更新する'

      assert_text 'ユーザーアイコンは指定された拡張子(PNG, JPG, JPEG, GIF, HEIC, HEIF形式)になっていないか、あるいは画像が破損している可能性があります'
    end

    test 'not show grass hide button for graduates' do
      visit_with_auth "/users/#{users(:sotugyou).id}", 'sotugyou'
      assert_text 'sotugyou'
      assert_no_button '非表示'
    end
  end
end

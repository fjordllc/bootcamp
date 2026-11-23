# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class ProfileTest < ApplicationSystemTestCase
    # プロフィールの表示の出し分けは test/integration/user_profile_display_test.rb で確かめる。
    test 'autolink profile when url is included' do
      url = 'https://bootcamp.fjord.jp/'
      visit_with_auth edit_current_user_path, 'kimura'
      fill_in 'user_description', with: "木村です。ブートキャンプはじめました。#{url}"
      click_button '更新する'
      assert_link url, href: url
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
  end
end

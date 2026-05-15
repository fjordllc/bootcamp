# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class AdminTest < ApplicationSystemTestCase
    test 'update admin user\'s retired_on' do
      user = users(:komagata)

      visit_with_auth '/current_user/edit', 'komagata'
      check '退会済', allow_label_click: true
      fill_in 'user[retired_on]', with: '2022-05-01'.to_date

      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      visit_with_auth '/current_user/edit', 'komagata'

      assert_equal '2022-05-01', user.reload.retired_on.to_s
    end

    test 'update admin user\'s graduated_on' do
      user = users(:komagata)

      visit_with_auth '/current_user/edit', 'komagata'
      check '卒業', allow_label_click: true
      fill_in 'user[graduated_on]', with: '2022-05-01'.to_date
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_equal '2022-05-01', user.reload.graduated_on.to_s
    end

    test 'update admin user\'s github_collaborator' do
      user = users(:komagata)

      visit_with_auth '/current_user/edit', 'komagata'
      uncheck 'GitHubチーム', allow_label_click: true

      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_not user.reload.github_collaborator
    end

    test 'update admin user\'s auto_retire' do
      visit_with_auth '/current_user/edit', 'komagata'
      check '休会三ヶ月後に自動退会しない', allow_label_click: true
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_not users(:komagata).reload.auto_retire
    end

    test 'update admin user\'s mentor' do
      visit_with_auth '/current_user/edit', 'komagata'
      uncheck 'メンター', allow_label_click: true
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_not users(:komagata).reload.mentor
    end

    test 'update admin user\'s subscription_id' do
      visit_with_auth '/current_user/edit', 'komagata'
      fill_in 'サブスクリプションID', with: 'sub_987654321'
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_equal 'sub_987654321', users(:komagata).reload.subscription_id
    end
  end
end

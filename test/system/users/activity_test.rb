# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class ActivityTest < ApplicationSystemTestCase
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
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class AccessControlTest < ApplicationSystemTestCase
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
  end
end

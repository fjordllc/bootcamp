# frozen_string_literal: true

require 'browserless_system_test_case'

module Users
  class ListBrowserlessTest < BrowserlessSystemTestCase
    test 'show listing all users' do
      visit_with_auth users_path, 'kimura'
      assert_equal '全てのユーザー | FBC', title
      assert_selector 'h2.page-header__title', text: 'ユーザー'
    end

    test 'not admin cannot see link to talk on user list page' do
      visit_with_auth '/users', 'kimura'
      assert_selector '.page-header__title', text: 'ユーザー'
      assert_no_link '相談部屋'
    end

    test 'show users trainees for adviser' do
      visit_with_auth '/users?target=trainee', 'senpai'
      assert_text '自社研修生'
    end

    test 'user can not see retired and hibernated tabs if the user is not admin or mentor' do
      visit_with_auth '/users', 'sotugyou'
      assert_no_link '休会', href: '/users?target=hibernated'
      assert_no_link '退会', href: '/users?target=retired'
    end
  end
end

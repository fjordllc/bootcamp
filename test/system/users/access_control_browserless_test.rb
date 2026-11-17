# frozen_string_literal: true

require 'browserless_system_test_case'

module Users
  class AccessControlBrowserlessTest < BrowserlessSystemTestCase
    test 'access by other users' do
      user = users(:hatsuno)
      visit_with_auth edit_admin_user_path(user.id), 'mentormentaro'
      assert_text '管理者としてログインしてください'
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
  end
end

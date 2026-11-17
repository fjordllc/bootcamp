# frozen_string_literal: true

require 'browserless_system_test_case'

module Users
  class AccessControlBrowserlessTest < BrowserlessSystemTestCase
    test 'access by other users' do
      user = users(:hatsuno)
      visit_with_auth edit_admin_user_path(user.id), 'mentormentaro'
      assert_text '管理者としてログインしてください'
    end
  end
end

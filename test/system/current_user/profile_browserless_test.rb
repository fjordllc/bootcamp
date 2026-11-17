# frozen_string_literal: true

require 'browserless_system_test_case'

module CurrentUser
  class ProfileBrowserlessTest < BrowserlessSystemTestCase
    test 'mentors can update their profiles' do
      visit_with_auth '/current_user/edit', 'komagata'
      assert_text 'プロフィール'
      assert_text 'プロフィール画像'
      assert_text 'プロフィール名'
      assert_text 'プロフィール文'
    end
  end
end

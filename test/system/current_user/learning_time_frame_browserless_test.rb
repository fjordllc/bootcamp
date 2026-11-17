# frozen_string_literal: true

require 'browserless_system_test_case'

module CurrentUser
  class LearningTimeFrameBrowserlessTest < BrowserlessSystemTestCase
    test 'visible learning time frames table for non advisors and grad users' do
      visit_with_auth '/current_user/edit', 'kimura'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_selector 'label.a-form-label', text: '主な活動予定時間'

      visit_with_auth '/current_user/edit', 'mentormentaro'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_selector 'label.a-form-label', text: '主な活動予定時間'

      visit_with_auth '/current_user/edit', 'kensyu'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_selector 'label.a-form-label', text: '主な活動予定時間'

      visit_with_auth '/current_user/edit', 'advijirou'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_no_selector 'label.a-form-label', text: '主な活動予定時間'

      visit_with_auth '/current_user/edit', 'sotugyou'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_no_selector 'label.a-form-label', text: '主な活動予定時間'
    end
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class LearningTimeFrameTest < ApplicationSystemTestCase
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

    test 'profile updates after setting activity time' do
      visit_with_auth '/current_user/edit', 'kimura'
      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_selector 'label.a-form-label', text: '主な活動予定時間'

      within '#learning_time_frame' do
        label1 = find('label[for="user_learning_time_frame_ids_1"]')
        scroll_to(label1)
        label1.click

        label25 = find('label[for="user_learning_time_frame_ids_25"]')
        scroll_to(label25)
        label25.click

        label49 = find('label[for="user_learning_time_frame_ids_49"]')
        scroll_to(label49)
        label49.click
      end

      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_selector 'h1.page-main-header__title', text: 'プロフィール'
      assert_selector 'h2.card-header__title', text: '主な活動予定時間'

      assert_selector 'td[name="checked_1"]'
      assert_selector 'td[name="checked_25"]'
      assert_selector 'td[name="checked_49"]'
    end
  end
end

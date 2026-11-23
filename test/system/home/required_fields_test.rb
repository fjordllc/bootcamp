# frozen_string_literal: true

require 'application_system_test_case'

module Home
  class RequiredFieldsTest < ApplicationSystemTestCase
    # 項目ごとの案内の出し分けは test/integration/dashboard_required_fields_test.rb で確かめる。
    # ここでは、案内から登録して案内が消えるまでの流れを確かめる。
    test 'visible announcement for activity time setup' do
      visit_with_auth '/', 'kimura'
      assert_selector 'h2.page-header__title', text: 'ダッシュボード'
      assert_link '活動時間を登録してください。', href: '/current_user/edit'
      click_on '活動時間を登録してください。'

      assert_selector 'h1.auth-form__title', text: '登録情報変更'
      assert_selector 'label.a-form-label', text: '主な活動予定時間'
      find('label[for="user_learning_time_frame_ids_1"]').click
      click_on '更新する'

      assert_text 'ユーザー情報を更新しました。'

      visit '/'
      assert_selector 'h2.page-header__title', text: 'ダッシュボード'
      assert_no_link '活動時間を登録してください。', href: '/current_user/edit'
    end
  end
end

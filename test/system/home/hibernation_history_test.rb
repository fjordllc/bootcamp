# frozen_string_literal: true

require 'application_system_test_case'

module Home
  class HibernationHistoryTest < ApplicationSystemTestCase
    test 'show my hibernation history on dashboard' do
      visit_with_auth '/', 'hukki'
      assert_selector '.card-header__title', text: '休会履歴（1回）'
      assert_selector '.user-metas__title', text: '1回目の休会'
    end

    test 'should not show hibernation history on dashboard when logged in user never hibernated' do
      visit_with_auth '/', 'kimura'
      assert_selector '.page-header__title', text: 'ダッシュボード'
      assert_no_selector '.card-header__title', text: '休会履歴（1回）'
      assert_no_selector '.user-metas__title', text: '1回目の休会'
    end
  end
end

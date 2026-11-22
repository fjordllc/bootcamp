# frozen_string_literal: true

require 'application_system_test_case'

module Home
  class GrassTest < ApplicationSystemTestCase
    test 'show grass hide button for graduates' do
      visit_with_auth '/', 'kimura'
      assert_no_button '非表示'

      visit_with_auth '/', 'sotugyou'
      assert_selector 'h2.card-header__title', text: '学習時間'
      click_button '非表示'
      assert_no_selector 'h2.card-header__title', text: '学習時間'
    end
  end
end

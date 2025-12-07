# frozen_string_literal: true

require 'application_system_test_case'

module CurrentUser
  class AddressTest < ApplicationSystemTestCase
    test 'display country and subdivision select box' do
      visit_with_auth '/current_user/edit', 'komagata'
      assert has_checked_field? 'register_address_no', visible: false
      assert_not has_css? '#country-form'
      assert_not has_css? '#subdivision-form'

      find('label[for=register_address_yes]').click
      assert has_css? '#country-form'
      assert_select 'user[country_code]', selected: '日本'
      assert has_css? '#subdivision-form'
      within('#subdivision-select') do
        assert_text '北海道'
      end
    end

    test 'do not register country and subdivision' do
      user = users(:kimura)
      assert_equal 'JP', user.country_code
      assert_equal '13', user.subdivision_code

      visit_with_auth '/current_user/edit', 'kimura'
      assert has_checked_field? 'register_address_yes', visible: false

      find('label[for=register_address_no]').click
      click_on '更新する'
      assert_text 'ユーザー情報を更新しました。'

      assert_nil user.reload.country_code
      assert_nil user.reload.subdivision_code
    end

    test 'change subdivisions' do
      visit_with_auth '/current_user/edit', 'kimura'
      within('#subdivision-select') do
        assert_text '北海道'
      end

      select '米国', from: 'user[country_code]'

      within('#subdivision-select') do
        assert_text 'アラスカ州'
      end
    end
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class ListTest < ApplicationSystemTestCase
    # 一覧と個別ページの表示の出し分けは test/integration/users/list_display_test.rb で確かめる。
    # ここでは、タブを押して一覧が切り替わることだけを確かめる。
    test 'students and trainees filter' do
      visit_with_auth '/users', 'komagata'
      click_link '現役 + 研修生'

      assert_selector('a.tab-nav__item-link.is-active', text: '現役 + 研修生')
      filtered_users = all('.users-item__icon .a-user-role')
      assert(filtered_users.all? do |user|
        classes = user[:class].split
        classes.include?('is-student') || classes.include?('is-trainee')
      end)
    end
  end
end

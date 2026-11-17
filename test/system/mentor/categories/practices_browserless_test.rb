# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::Categories::PracticesBrowserlessTest < BrowserlessSystemTestCase
  test 'admin user can access practices sort page' do
    visit_with_auth mentor_category_practices_path(categories(:category2)), 'komagata'
    within first('.admin-table__item-value.is-text-align-center.is-grab') do
      assert_selector '.js-grab'
    end
  end

  test 'non-admin user cannot access practices sort page' do
    visit_with_auth mentor_category_practices_path(categories(:category2)), 'kimura'
    assert_text '管理者・メンターとしてログインしてください'
  end
end

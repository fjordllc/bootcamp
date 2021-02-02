# frozen_string_literal: true

require 'application_system_test_case'

class Practice::SortTest < ApplicationSystemTestCase
  test 'admin user can access practices sort page' do
    login_user 'komagata', 'testtest'
    visit course_sort_index_path(courses(:course1).id)
    within('.categories-items__inner') do
      assert_selector '.grab'
    end
  end

  test 'non-admin user cannot access practices sort page' do
    login_user 'kimura', 'testtest'
    visit course_sort_index_path(courses(:course1).id)
    assert_text '管理者としてログインしてください'
  end
end

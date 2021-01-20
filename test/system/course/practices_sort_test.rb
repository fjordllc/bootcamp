# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesSortTest < ApplicationSystemTestCase
  test '管理者がプラクティス並び替えページにアクセスする' do
    login_user 'komagata', 'testtest'
    visit course_practices_sort_path(courses(:course1).id)
    within('.categories-items__inner') do
      assert_selector '.grab'
    end
  end

  test '管理者以外はプラクティス並び替えページにアクセスできない' do
    login_user 'kimura', 'testtest'
    visit course_practices_sort_path(courses(:course1).id)
    assert_text '管理者としてログインしてください'
  end
end

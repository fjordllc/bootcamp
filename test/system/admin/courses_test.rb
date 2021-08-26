# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CoursesTest < ApplicationSystemTestCase
  test 'show listing courses' do
    visit_with_auth 'admin/courses', 'komagata'
    assert_equal 'コース一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end

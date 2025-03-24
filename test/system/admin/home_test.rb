# frozen_string_literal: true

require 'application_system_test_case'

class Admin::HomeTest < ApplicationSystemTestCase
  test 'GET /admin' do
    visit_with_auth '/admin', 'komagata'
    assert_equal '管理ページ | FBC', title
  end
end

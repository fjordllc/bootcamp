# frozen_string_literal: true

require 'application_system_test_case'

class Admin::PracticesTest < ApplicationSystemTestCase
  test 'show listing practices' do
    visit_with_auth '/admin/practices', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show practice page' do
    visit_with_auth admin_practices_path, 'komagata'
    first('.admin-table__item').assert_text 'sshdでパスワード認証を禁止にする'
  end
end

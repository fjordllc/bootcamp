# frozen_string_literal: true

require 'application_system_test_case'

class Admin::HomeTest < ApplicationSystemTestCase
  test 'GET /admin' do
    visit_with_auth '/admin', 'komagata'
    assert_equal '管理ページ | FBC', title

    tabs = %w[FAQ FAQカテゴリー お問い合わせ お試し延長 ユーザー 企業 招待URL 管理ページ].sort
    assert_equal tabs, all('a.page-tabs__item-link').map(&:text).sort
    assert_no_selector '.page-tabs__item-link', text: 'プラクティス'
    assert_no_selector '.page-tabs__item-link', text: 'コース'
  end
end

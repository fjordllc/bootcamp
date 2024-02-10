# frozen_string_literal: true

require 'application_system_test_case'

class Admin::HomeTest < ApplicationSystemTestCase
  test 'GET /admin' do
    visit_with_auth '/admin', 'komagata'
    assert_equal '管理ページ | FBC', title

    assert_selector 'a.page-tabs__item-link', count: 5
    assert_selector '.page-tabs__item-link', text: '管理ページ'
    assert_selector '.page-tabs__item-link', text: 'ユーザー'
    assert_selector '.page-tabs__item-link', text: '企業'
    assert_selector '.page-tabs__item-link', text: 'お試し延長'
    assert_selector '.page-tabs__item-link', text: 'FAQ'
    assert_no_selector '.page-tabs__item-link', text: 'プラクティス'
    assert_no_selector '.page-tabs__item-link', text: 'カテゴリー'
    assert_no_selector '.page-tabs__item-link', text: 'コース'
  end
end

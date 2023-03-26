# frozen_string_literal: true

require 'application_system_test_case'

class Admin::HomeTest < ApplicationSystemTestCase
  test 'GET /admin' do
    visit_with_auth '/admin', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_selector '.page-tabs__item-link', text: '管理ページ', visible: true
    assert_selector '.page-tabs__item-link', text: 'ユーザー', visible: true
    assert_selector '.page-tabs__item-link', text: '企業', visible: true
    assert_selector '.page-tabs__item-link', text: 'お試し延長', visible: true
    assert_no_selector '.page-tabs__item-link', text: 'プラクティス', visible: true
    assert_no_selector '.page-tabs__item-link', text: 'カテゴリー', visible: true
    assert_no_selector '.page-tabs__item-link', text: 'コース', visible: true
  end
end

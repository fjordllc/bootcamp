# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::HomeTest < ApplicationSystemTestCase
  test 'GET /mentor' do
    visit_with_auth '/mentor', 'komagata'
    assert_equal 'メンターページ | FBC', title
    assert_no_text 'jobseeker (シュウカツ ノゾム)'
    assert_text 'muryou (ムリョウ ノスケ)'
    assert_selector '.page-tabs__item-link', text: 'メンターページ', visible: true
    assert_selector '.page-tabs__item-link', text: 'プラクティス', visible: true
    assert_selector '.page-tabs__item-link', text: 'カテゴリー', visible: true
    assert_selector '.page-tabs__item-link', text: 'コース', visible: true
    assert_no_selector '.page-tabs__item-link', text: 'ユーザー', visible: true
    assert_no_selector '.page-tabs__item-link', text: '企業', visible: true
    assert_no_selector '.page-tabs__item-link', text: 'お試し延長', visible: true
  end

  test 'accessed by non-mentor users' do
    visit_with_auth '/mentor', 'kimura'
    assert_text 'メンターとしてログインしてください'
  end
end

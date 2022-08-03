# frozen_string_literal: true

require 'application_system_test_case'

class Practice::QuestionsTest < ApplicationSystemTestCase
  test 'show listing questions' do
    visit_with_auth "/practices/#{practices(:practice1).id}/questions", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FBC', title
  end

  test 'show a WIP question on the all questions list ' do
    visit_with_auth "/practices/#{practices(:practice1).id}/questions", 'hatsuno'
    assert_text 'wipテスト用の質問(wip中)'
  end

  test 'not show a WIP question on the unsolved questions list ' do
    visit_with_auth "/practices/#{practices(:practice1).id}/questions?target=not_solved", 'hatsuno'
    assert_no_text 'wipテスト用の質問(wip中)'
    assert_selector('a.tab-nav__item-link.is-active', text: '未解決')
  end
end

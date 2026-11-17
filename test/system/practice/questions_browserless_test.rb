# frozen_string_literal: true

require 'browserless_system_test_case'

class Practice::QuestionsBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing questions' do
    visit_with_auth "/practices/#{practices(:practice1).id}/questions", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関するQ&A | FBC', title
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

  test 'show all questions from both grant and source practices when all filter is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    assert_selector '.pill-nav__item-link.is-active', exact_text: '全て'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '全ての質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show total question count from grant and source practices when all scope is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    assert_selector '.page-tabs__item-link.is-active', exact_text: '質問 （4）'
  end

  test 'show total question count from grant and source practices on non-question pages' do
    visit_with_auth "/practices/#{practices(:practice64).id}", 'grant-course'
    assert_selector '.page-tabs__item-link', exact_text: '質問 （4）'
  end
end

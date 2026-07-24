# frozen_string_literal: true

require 'application_system_test_case'

class Practice::QuestionsTest < ApplicationSystemTestCase
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

  test 'show grant course filter tabs only for grant course practices' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    assert_selector '.pill-nav__item-link', exact_text: '全て'
    assert_selector '.pill-nav__item-link', exact_text: '給付金コース'

    visit_with_auth "/practices/#{practices(:practice1).id}/questions", 'grant-course'
    assert_no_selector '.pill-nav__item-link', exact_text: '全て'
    assert_no_selector '.pill-nav__item-link', exact_text: '給付金コース'
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

  test 'show solved questions from both grant and source practices when solved filter is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.tab-nav' do
      click_on '解決済み'
    end
    assert_selector '.pill-nav__item-link.is-active', exact_text: '全て'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '解決済み'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show unsolved questions from both grant and source practices when unsolved filter is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.tab-nav' do
      click_on '未解決'
    end
    assert_selector '.pill-nav__item-link.is-active', exact_text: '全て'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '未解決'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show all questions only from the grant practice when grant course scope is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.pill-nav' do
      click_on '給付金コース'
    end
    assert_selector '.pill-nav__item-link.is-active', exact_text: '給付金コース'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '全ての質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show solved questions only from the grant practice when solved filter and grant course scope are selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.pill-nav' do
      click_on '給付金コース'
    end
    within '.tab-nav' do
      click_on '解決済み'
    end
    assert_selector '.pill-nav__item-link.is-active', exact_text: '給付金コース'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '解決済み'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show unsolved questions only from the grant practice when unsolved filter and grant course scope are selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.pill-nav' do
      click_on '給付金コース'
    end
    within '.tab-nav' do
      click_on '未解決'
    end
    assert_selector '.pill-nav__item-link.is-active', exact_text: '給付金コース'
    assert_selector '.tab-nav__item-link.is-active', exact_text: '未解決'
    assert_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのプラクティスの質問(解決済み)'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問'
    assert_no_selector '.card-list-item-title__link', exact_text: '給付金コースのコピー元プラクティスの質問(解決済み)'
  end

  test 'show total question count from grant and source practices when all scope is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    assert_selector '.page-tabs__item-link.is-active', exact_text: '質問 （4）'
  end

  test 'show question count from grant practice only when grant course scope is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/questions", 'grant-course'
    within '.pill-nav' do
      click_on '給付金コース'
    end
    assert_selector '.page-tabs__item-link.is-active', exact_text: '質問 （2）'
  end

  test 'show total question count from grant and source practices on non-question pages' do
    visit_with_auth "/practices/#{practices(:practice64).id}", 'grant-course'
    assert_selector '.page-tabs__item-link', exact_text: '質問 （4）'
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/practices/#{practices(:practice1).id}/reports", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する日報 | FBC', title
    assert_selector 'img[alt="positive"]', count: 2
    assert_selector '.card-list-item-title__link', text: '1時間だけ学習'
  end

  test 'grant filter is not present on rails course practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}/reports", 'komagata'
    assert_selector '.card-list-item-title__link'
    assert_no_selector '[data-grant-filter]'
  end

  test 'grant filter is present on grant course practice' do
    visit_with_auth "/practices/#{practices(:practice64).id}/reports", 'komagata'
    assert_selector '.card-list-item-title__link'
    assert_selector '[data-grant-filter]'
  end

  test 'grant filter shows both copied and grant course reports when "全て" is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/reports", 'komagata'
    assert_selector '.card-list-item-title__link'
    assert_selector 'button.pill-nav__item-link.is-active[data-with-grant="false"]', text: '全て'
    assert_selector '.card-list-item-title__link', text: 'コピー元のRailsコースのプラクティスの日報'
    assert_selector '.card-list-item-title__link', text: '給付金コースのプラクティスの日報'
  end

  test 'grant filter shows only grant course reports when "給付金コース" is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/reports", 'komagata'
    assert_selector '.card-list-item-title__link'
    find('button[data-with-grant="true"]').click
    assert_selector 'button.pill-nav__item-link.is-active[data-with-grant="true"]', text: '給付金コース'
    assert_no_selector '.card-list-item-title__link', text: 'コピー元のRailsコースのプラクティスの日報'
    assert_selector '.card-list-item-title__link', text: '給付金コースのプラクティスの日報'
  end

  test 'grant filter shows empty message when no reports exist' do
    visit_with_auth "/practices/#{practices(:practice65).id}/reports", 'komagata'
    assert_selector '[data-grant-filter]'
    find('button[data-with-grant="true"]').click
    assert_selector 'button.pill-nav__item-link.is-active[data-with-grant="true"]', text: '給付金コース'
    assert_selector '.o-empty-message__text', text: '日報はまだありません。'
  end
end

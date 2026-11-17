# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ReportsTest < ApplicationSystemTestCase
  test 'grant filter shows only grant course reports when "給付金コース" is selected' do
    visit_with_auth "/practices/#{practices(:practice66).id}/reports", 'komagata'
    within '.pill-nav' do
      click_on '給付金コース'
    end

    assert_selector 'a.pill-nav__item-link.is-active', text: '給付金コース'
    assert_no_selector '.card-list-item-title__link', text: 'Railsコースのコピー元プラクティスの日報'
    assert_selector '.card-list-item-title__link', text: '給付金コースのプラクティスの日報'
  end

  test 'grant filter shows empty message when no reports exist' do
    visit_with_auth "/practices/#{practices(:practice68).id}/reports", 'komagata'
    within '.pill-nav' do
      click_on '給付金コース'
    end

    assert_selector 'a.pill-nav__item-link.is-active', text: '給付金コース'
    assert_no_selector '.card-list-item-title__link'
    assert_selector '.o-empty-message__text', text: '日報はまだありません。'
  end
end

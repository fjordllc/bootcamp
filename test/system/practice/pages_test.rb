# frozen_string_literal: true

require 'application_system_test_case'

class Practice::PagesTest < ApplicationSystemTestCase
  test 'show listing pages' do
    visit_with_auth "/practices/#{practices(:practice1).id}/pages", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関するDocs | FBC', title
    assert_selector 'h2.page-header__title', text: 'OS X Mountain Lionをクリーンインストールする'
  end

  test 'show last updated user icon and role' do
    visit_with_auth "/practices/#{practices(:practice1).id}/pages", 'hajime'
    within '.card-list-item-meta__icon-link', match: :first do
      assert_selector 'span.a-user-role.is-admin'
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
      assert_selector 'img[class="card-list-item-meta__icon a-user-icon"]'
    end

    visit_with_auth "/practices/#{practices(:practice2).id}/pages", 'hajime'
    within '.card-list-item-meta__icon-link' do
      assert_selector 'span.a-user-role.is-student'
      assert_selector 'img[alt="kimura (Kimura Tadasi)"]'
      assert_selector 'img[class="card-list-item-meta__icon a-user-icon"]'
    end
  end

  test 'grant filter is not present on rails course practice' do
    visit_with_auth "/practices/#{practices(:practice1).id}/pages", 'komagata'
    assert_no_selector '.pill-nav__items'
  end

  test 'grant filter is present on grant course practice' do
    visit_with_auth "/practices/#{practices(:practice64).id}/pages", 'komagata'
    assert_selector '.pill-nav__items'
  end

  test 'grant filter shows both copied and grant course docs when "全て" is selected' do
    visit_with_auth "/practices/#{practices(:practice64).id}/pages", 'komagata'
    assert_selector '.pill-nav__item-link.is-active', text: '全て'
    assert_selector '.card-list-item-title__link.a-text-link', text: 'コピー元のRailsコースのプラクティスのDocs'
    assert_selector '.card-list-item-title__link.a-text-link', text: '給付金コースのプラクティスに紐づいたDocs'
  end

    test 'grant filter shows only grant course reports when "給付金コース" is selected' do
      visit_with_auth "/practices/#{practices(:practice64).id}/pages", 'komagata'
      find('.pill-nav__item-link',text: '給付金コース').click
      assert_selector '.pill-nav__item-link.is-active', text: '給付金コース'
      assert_no_selector '.card-list-item-title__link.a-text-link', text: 'コピー元のRailsコースのプラクティスのDocs'
      assert_selector '.card-list-item-title__link.a-text-link', text: '給付金コースのプラクティスに紐づいたDocs'
    end

    test 'grant filter shows empty message when no reports exist' do
      visit_with_auth "/practices/#{practices(:practice65).id}/pages", 'komagata'
      assert_selector '.pill-nav__items'
      find('.pill-nav__item-link',text: '給付金コース').click
      assert_selector '.pill-nav__item-link.is-active', text: '給付金コース'
      assert_selector '.o-empty-message__text', text: 'Docはまだありません'
    end
end

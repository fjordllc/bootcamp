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
    within '.card-list-item-meta__icon-link' do
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

  test 'show grant filter with all tab active by default' do
    normal_practice = Practice.create!(
      title: 'テスト用プラクティス 通常コース',
      description: 'テスト用',
      categories: [categories(:category1)],
      goal: 'goal...'
    )
    grant_practice = Practice.create!(
      title: 'テスト用プラクティス 給付金コース',
      description: 'テスト用',
      categories: [categories(:category1)],
      goal: 'goal...',
      source_practice: normal_practice
    )
    normal_page = Page.create!(title: '通常のプラクティスDoc', body: '本文', user: users(:kimura), practice: normal_practice)
    grant_page = Page.create!(title: '給付金のプラクティスDoc', body: '本文', user: users(:kimura), practice: grant_practice)

    visit_with_auth "/practices/#{grant_practice.id}/pages", 'grant-course'
    assert_selector 'a.pill-nav__item-link', count: 2
    assert_selector 'a.pill-nav__item-link.is-active', text: '全て'
    assert_selector 'a.pill-nav__item-link', text: '給付金コース'
    assert_selector '.card-list-item-title__link', text: normal_page.title
    assert_selector '.card-list-item-title__link', text: grant_page.title
  end
end

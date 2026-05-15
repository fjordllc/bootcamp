# frozen_string_literal: true

require 'application_system_test_case'

class SearchablesTest < ApplicationSystemTestCase
  test 'search with word' do
    visit_with_auth '/', 'hatsuno'
    search_word = '検索結果テスト用'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: search_word
    end
    find('#test-search-modal').click
    # 検索結果が表示されるまで待機
    assert_selector '.card-list-item'
    # 検索結果が表示されていることを確認
    assert_text search_word
  end

  test 'matched_word is in bold' do
    visit_with_auth '/', 'komagata'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: '検索ワードが太字で表示されるかのテスト'
    end
    find('#test-search-modal').click
    assert_selector 'strong.matched_word', text: '検索ワードが太字で表示されるかのテスト'
  end

  test 'show icon and go profile page when click icon' do
    user = users(:komagata)
    reset_avatar(user)
    user.reload
    assert user.avatar.attached?, 'アバターのテスト用フィクスチャがアタッチできませんでした（komagata）'
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: '提出物のコメントです。'
    end
    find('#test-search-modal').click
    assert_includes find('img.card-list-item-meta__icon.a-user-icon')['src'], 'komagata.webp'

    find('img.card-list-item-meta__icon.a-user-icon').click
    assert_selector 'h1.page-content-header__title', text: 'komagata'
  end
end

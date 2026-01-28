# frozen_string_literal: true

require 'application_system_test_case'

class SmartSearchTest < ApplicationSystemTestCase
  test 'search mode selector is displayed' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_text '検索方法'
      assert_text 'キーワード検索'
      assert_text 'AI検索'
      assert_text 'ハイブリッド'
    end
  end

  test 'search with keyword mode' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      choose 'キーワード検索'
      fill_in 'word', with: '検索結果テスト用'
    end
    find('#test-search-modal').click
    assert_selector '.card-list-item'
    assert_text '検索結果テスト用'
  end

  test 'search mode is preserved in search results page' do
    visit_with_auth searchables_path(word: 'テスト', mode: 'semantic'), 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_selector 'input[name=mode][value=semantic][checked]'
    end
  end

  test 'keyword mode is default when mode param is not specified' do
    visit_with_auth searchables_path(word: 'テスト'), 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_selector 'input[name=mode][value=keyword][checked]'
    end
  end
end

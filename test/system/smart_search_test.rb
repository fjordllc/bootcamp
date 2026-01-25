# frozen_string_literal: true

require 'application_system_test_case'

class SmartSearchTest < ApplicationSystemTestCase
  setup do
    Switchlet.enable!(:smart_search)
  end

  test 'search mode selector is displayed when smart_search is enabled' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_text '検索方法'
      assert_selector 'select[name=mode]'
    end
  end

  test 'search with keyword mode' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      select 'キーワード検索', from: 'mode'
      fill_in 'word', with: '検索結果テスト用'
    end
    find('#test-search-modal').click
    assert_selector '.card-list-item'
    assert_text '検索結果テスト用'
  end

  test 'search mode options include AI search and hybrid' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_selector 'select[name=mode] option', text: 'キーワード検索'
      assert_selector 'select[name=mode] option', text: 'AI検索'
      assert_selector 'select[name=mode] option', text: 'ハイブリッド'
    end
  end

  test 'search mode is preserved in search results page' do
    visit_with_auth searchables_path(word: 'テスト', mode: 'semantic'), 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_selector 'select[name=mode] option[selected]', text: 'AI検索'
    end
  end

  test 'keyword mode is default when mode param is not specified' do
    visit_with_auth searchables_path(word: 'テスト'), 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_selector 'select[name=mode] option[selected]', text: 'キーワード検索'
    end
  end

  test 'search mode selector is not displayed when smart_search is disabled' do
    Switchlet.disable!(:smart_search)
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      assert_no_text '検索方法'
      assert_no_selector 'select[name=mode]'
    end
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

module Searchables
  class DocumentTypeTest < ApplicationSystemTestCase
    test 'search with document_type' do
      visit_with_auth '/', 'hatsuno'
      document_type = '日報'
      search_word = '検索結果テスト用'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select document_type
        fill_in 'word', with: search_word
        click_button '検索'
      end
      labels = all('.card-list-item__label')
      assert_equal 1, labels.count
      labels.each do |label|
        assert_equal label.text, document_type
      end
    end

    test 'search events' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'イベント'
        fill_in 'word', with: 'テストのイベント'
      end
      find('#test-search-modal').click
      assert_text 'テストのイベント'
    end

    test 'search regular_events' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'イベント'
        fill_in 'word', with: '定期イベントの検索結果テスト用'
      end
      find('#test-search-modal').click
      assert_text '定期イベントの検索結果テスト用'
    end

    test 'show user icon, name and updated time in report' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select '日報'
        fill_in 'word', with: 'テストの日報'
      end
      find('#test-search-modal').click
      assert_text 'mentormentaro'
      assert_css '.a-meta'
      assert_css 'img.card-list-item-meta__icon.a-user-icon'
      assert_no_text 'テストの回答'
    end
  end
end

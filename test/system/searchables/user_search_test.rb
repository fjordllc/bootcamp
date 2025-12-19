# frozen_string_literal: true

require 'application_system_test_case'

module Searchables
  class UserSearchTest < ApplicationSystemTestCase
    test 'search user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'komagata'
      end
      find('#test-search-modal').click
      assert_selector '.card-list-item'
      assert_text 'komagata'
      assert_no_text 'PC性能の見方を知る'
    end

    test 'can search user with nil description' do
      visit_with_auth '/', 'hatsuno'
      kimura = users(:kimura)
      kimura.update_attribute(:description, nil) # rubocop:disable Rails/SkipsModelValidations
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'kimura'
      end
      find('#test-search-modal').click
      assert_selector '.card-list-item'
      assert_text 'kimura'
    end

    test 'link to consultation room does not appear except for administrator' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'komagata'
      end
      find('#test-search-modal').click
      assert_selector '.card-list-item'
      assert_text 'komagata'
      assert_no_text '相談部屋'
    end

    test 'empty keyword search returns no results' do
      visit_with_auth '/', 'komagata'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: ''
      end
      find('#test-search-modal').click
      assert_selector '.o-empty-message'
      assert_text 'に一致する情報は見つかりませんでした。'
    end

    test 'administrator will see link to consultation room' do
      visit_with_auth '/', 'komagata'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'komagata'
      end
      find('#test-search-modal').click
      assert_selector '.card-list-item'
      assert_text '相談部屋'
    end

    test 'disappear icon when search user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'hajime'
      end
      find('#test-search-modal').click
      assert_selector '.card-list-item'
      assert_no_css 'img.card-list-item-meta__icon.a-user-icon'
    end

    test 'search with all scope includes retired user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'yameo'
      end
      find('#test-search-modal').click
      within('.card-list-item.is-user') do
        assert_text 'yameo'
      end
    end

    test 'search with all scope includes hibernated user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'kyuukai'
      end
      find('#test-search-modal').click
      within('.card-list-item.is-user') do
        assert_text 'kyuukai'
      end
    end

    test 'search with user scope includes retired user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'yameo'
      end
      find('#test-search-modal').click
      within('.card-list-item.is-user') do
        assert_text 'yameo'
      end
    end

    test 'search with user scope includes hibernated user' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'ユーザー'
        fill_in 'word', with: 'kyuukai'
      end
      find('#test-search-modal').click
      within('.card-list-item.is-user') do
        assert_text 'kyuukai'
      end
    end
  end
end

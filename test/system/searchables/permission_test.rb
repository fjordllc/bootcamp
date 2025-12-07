# frozen_string_literal: true

require 'application_system_test_case'

module Searchables
  class PermissionTest < ApplicationSystemTestCase
    test 'admin can see comment description' do
      visit_with_auth '/', 'komagata'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'テストの日報'
      end
      find('#test-search-modal').click
      assert_text 'テストの日報'
    end

    test 'advisor can see comment description' do
      visit_with_auth '/', 'advijirou'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'テストの日報'
      end
      find('#test-search-modal').click
      assert_text 'テストの日報'
    end

    test 'can see comment description if it is permitted' do
      visit_with_auth '/', 'kimura'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'テストの日報'
      end
      find('#test-search-modal').click
      assert_text 'テストの日報'
    end

    test "can not see comment description if it isn't permitted" do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: 'テストの日報'
      end
      find('#test-search-modal').click
      assert_text 'テストの日報'
    end

    test 'returns document author name when comment' do
      visit_with_auth '/', 'hatsuno'
      find('.js-modal-search-shown-trigger').click
      within('form[name=search]') do
        select 'すべて'
        fill_in 'word', with: '提出物のコメントです。'
      end
      find('#test-search-modal').click
      assert_text 'komagata'
      assert_text 'kimura'
      assert_no_text 'machida'
    end
  end
end

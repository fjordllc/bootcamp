# frozen_string_literal: true

require 'application_system_test_case'

class SearchablesTest < ApplicationSystemTestCase
  test 'search All ' do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: '検索結果テスト用'
    end
    find('#test-search').click
    assert_text 'お知らせの検索結果テスト用'
    assert_text 'プラクティスの検索結果テスト用'
    assert_text '日報の検索結果テスト用'
    assert_text '提出物の検索結果テスト用'
    assert_text 'Q&Aの検索結果テスト用'
    assert_text 'Docsの検索結果テスト用'
    assert_text 'イベントの検索結果テスト用'
  end

  test 'search reports ' do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select '日報'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'テストの日報'
  end

  test 'search events' do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select 'イベント'
      fill_in 'word', with: 'テストのイベント'
    end
    find('#test-search').click
    assert_text 'テストのイベント'
  end

  test 'admin can see comment description' do
    visit_with_auth '/', 'komagata'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'テストの日報'
  end

  test 'advisor can see comment description' do
    visit_with_auth '/', 'advijirou'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'テストの日報'
  end

  test 'can see comment description if it is permitted' do
    visit_with_auth '/', 'kimura'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'テストの日報'
  end

  test "can not see comment description if it isn't permitted" do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'テストの日報'
  end

  test 'show user name and updated time' do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select '日報'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'yamada'
    assert_css '.a-date'
    assert_no_text 'テストの回答'
  end

  test 'search user' do
    visit_with_auth '/', 'hatsuno'
    within('form[name=search]') do
      select 'ユーザー'
      fill_in 'word', with: 'komagata'
    end
    find('#test-search').click
    assert_text 'komagata'
    assert_no_text 'PC性能の見方を知る'
  end

  test 'can search user with nil description' do
    visit_with_auth '/', 'hatsuno'
    kimura = users(:kimura)
    kimura.update_attribute(:description, nil) # rubocop:disable Rails/SkipsModelValidations
    within('form[name=search]') do
      select 'ユーザー'
      fill_in 'word', with: 'kimura'
    end
    find('#test-search').click
    assert_text 'kimura'
  end
end

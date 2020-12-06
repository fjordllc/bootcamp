# frozen_string_literal: true

require 'application_system_test_case'

class SearchablesTest < ApplicationSystemTestCase
  setup { login_user 'hatsuno', 'testtest' }

  test 'search All ' do
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_text 'テストの日報'
    assert_text 'Docsページ'
    assert_text 'Unityでのテスト'
    assert_text 'テストの質問1'
    assert_text 'テストのお知らせ'
    assert_text 'テスト用 report1へのコメント'
    assert_text 'テスト用 announcement1へのコメント'
    assert_text 'テストの回答'
  end

  test 'search reports ' do
    within('form[name=search]') do
      select '日報'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_text 'テストの日報'
    assert_no_text 'Docsページ'
    assert_no_text 'Unityでのテスト'
    assert_no_text 'テストの質問1'
    assert_no_text 'テストのお知らせ'
    assert_text 'テスト用 report1へのコメント'
    assert_no_text 'テスト用 announcement1へのコメント'
  end

  test 'admin can see comment description' do
    login_user 'komagata', 'testtest'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_text 'テスト用 product1へのコメント'
  end

  test 'advisor can see comment description' do
    login_user 'advijirou', 'testtest'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_text 'テスト用 product1へのコメント'
  end

  test 'can see comment description if it is permitted' do
    login_user 'kimura', 'testtest'
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_text 'テスト用 product1へのコメント'
    assert_text 'テスト用 product3へのコメント'
  end

  test "can not see comment description if it isn't permitted" do
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: 'テスト'
    end
    find('#test-search').click
    assert_no_text 'テスト用 product1へのコメント'
    assert_text 'テスト用 product3へのコメント'
    assert_text '該当プラクティスを完了するまで他の人の提出物へのコメントは見れません。'
  end

  test 'show user name and updated time' do
    within('form[name=search]') do
      select '日報'
      fill_in 'word', with: 'テストの日報'
    end
    find('#test-search').click
    assert_text 'yamada'
    assert_css '.thread-list-item-meta__updated-at'
    assert_no_text 'テストの回答'
  end
end

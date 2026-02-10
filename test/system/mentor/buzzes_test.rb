# frozen_string_literal: true

require 'application_system_test_case'
require 'test_helper'

class Mentor::BuzzesTest < ApplicationSystemTestCase
  test 'show listing buzzes' do
    visit_with_auth mentor_buzzes_path, 'machida'
    assert_equal '紹介・言及記事 | FBC', title
  end

  test 'buzzes are listed in descending order of published_at' do
    dates = %w[2024-12-25 2025-04-01 2025-09-10]
    create_buzzes(dates)
    visit_with_auth mentor_buzzes_path, 'machida'
    buzz_titles = all('.admin-table__item').map { |row| row.find('td:first-child a').text }
    expected_order = %w[2025-09-10の記事 2025-04-01の記事 2024-12-25の記事]
    assert_equal expected_order, buzz_titles
  end

  test 'displays title and published date extracted when url submitted' do
    dummy_response = <<~BODY
      <title>2025-09-10の記事</title>
      <meta property="article:published_time" content="2025-09-10T02:21:55Z" />
    BODY
    stub_request(:get, 'https://www.example.com')
      .to_return(status: 200, body: dummy_response)
    visit_with_auth new_mentor_buzz_path, 'machida'
    within 'form[name=buzz]' do
      fill_in 'buzz[url]', with: 'https://www.example.com'
      click_button '登録する'
    end
    assert_text '2025-09-10の記事'
    assert_text '2025-09-10'
  end

  test 'displays error when no url submitted' do
    visit_with_auth new_mentor_buzz_path, 'machida'
    within 'form[name=buzz]' do
      fill_in 'buzz[title]', with: '2025-09-10の記事'
      fill_in 'buzz[published_at]', with: Date.new(2025, 9, 10)
      click_button '登録する'
    end
    assert_text 'Urlを入力してください'
  end

  test 'url field is not shown in buzz edit form' do
    buzz = create_buzz('2025-09-10')
    visit_with_auth edit_mentor_buzz_path(buzz.id), 'machida'
    within 'form[name=buzz]' do
      assert_no_selector 'input[name="buzz[url]"]'
    end
  end

  test 'user can change title and published date when creating buzz' do
    dummy_response = <<~BODY
      <title>2025-09-10の記事</title>
      <meta property="article:published_time" content="2025-09-10T02:21:55Z" />
    BODY
    stub_request(:get, 'https://www.example.com')
      .to_return(status: 200, body: dummy_response)
    visit_with_auth new_mentor_buzz_path, 'machida'
    within 'form[name=buzz]' do
      fill_in 'buzz[title]', with: '最新の記事'
      fill_in 'buzz[url]', with: 'https://www.example.com'
      fill_in 'buzz[published_at]', with: Date.new(2025, 10, 1)
      click_button '登録する'
    end
    assert_text '最新の記事'
    assert_text '2025年10月01日'
    assert_no_text '2025-09-10の記事'
    assert_no_text '2025年09月10日'
  end

  test 'user can update title memo and published date' do
    buzz = Buzz.create!(title: '新しいBuzz', url: 'https://www.example.com', memo: '新しいBuzzです', published_at: '2025-09-10')
    visit_with_auth edit_mentor_buzz_path(buzz.id), 'machida'
    within 'form[name=buzz]' do
      fill_in 'buzz[title]', with: '編集後のBuzz'
      fill_in 'buzz[memo]', with: '編集しました'
      fill_in 'buzz[published_at]', with: Date.new(2025, 9, 11)
      click_button '更新する'
    end
    assert_text '編集後のBuzz'
    assert_text '編集しました'
    assert_text '2025年09月11日'
    assert_no_text '新しいBuzz'
    assert_no_text '新しいBuzzです'
    assert_no_text '2025年09月10日'
  end

  test 'user can destroy buzz' do
    buzz = Buzz.create!(title: '新しいBuzz', url: 'https://www.example.com', published_at: '2025-09-10')
    visit_with_auth edit_mentor_buzz_path(buzz.id), 'machida'
    accept_confirm do
      click_button '削除する'
    end
    assert_no_text '新しいBuzz'
  end
end

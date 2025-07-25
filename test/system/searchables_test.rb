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
    summaries = all('.card-list-item__summary.p')
    summaries.each do |summary|
      assert_includes summary.text, search_word
    end
  end

  test 'search with document_type' do
    visit_with_auth '/', 'hatsuno'
    document_type = '日報'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select document_type
    end
    find('#test-search-modal').click
    labels = all('.card-list-item__label')
    assert_equal labels.count, 50
    assert_equal labels[3].text, document_type
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

  test 'search user' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'ユーザー'
      fill_in 'word', with: 'komagata'
    end
    find('#test-search-modal').click
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
    assert_text 'kimura'
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

  test 'link to consultation room does not appear except for administrator' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'すべて'
      fill_in 'word', with: ''
    end
    find('#test-search-modal').click
    assert_no_text '相談部屋'
  end

  test 'administrator will see link to consultation room' do
    visit_with_auth '/', 'komagata'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'ユーザー'
      fill_in 'word', with: ''
    end
    find('#test-search-modal').click
    assert_text '相談部屋'
  end

  test 'show icon and go profile page when click icon' do
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

  test 'disappear icon when search user' do
    visit_with_auth '/', 'hatsuno'
    find('.js-modal-search-shown-trigger').click
    within('form[name=search]') do
      select 'ユーザー'
      fill_in 'word', with: 'hajime'
    end
    find('#test-search-modal').click
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

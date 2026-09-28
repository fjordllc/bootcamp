# frozen_string_literal: true

require 'application_system_test_case'

class HeaderTest < ApplicationSystemTestCase
  test 'show help dropdown' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: 'ヘルプ').click

    assert_text '受講生用ヘルプ'
    assert_text 'アドバイザー用ヘルプ'
  end

  test 'close search modal with Escape key' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: '検索').click
    assert_selector '#js-modal-search.is-shown'

    page.send_keys(:escape)

    assert_no_selector '#js-modal-search.is-shown'
  end

  test 'close help dropdown with Escape key' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: 'ヘルプ').click
    assert_selector 'button.header-links__link.is-opened-dropdown'

    page.send_keys(:escape)

    assert_no_selector 'button.header-links__link.is-opened-dropdown'
  end

  test 'close user dropdown with Escape key' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: 'Me').click
    assert_selector 'button.header-links__link.is-opened-dropdown'

    page.send_keys(:escape)

    assert_no_selector 'button.header-links__link.is-opened-dropdown'
  end

  test 'close notifications dropdown with Escape key' do
    visit_with_auth root_path, 'komagata'

    find('#notifications-bell-button').click
    assert_no_selector '#notifications-dropdown.is-hidden'

    page.send_keys(:escape)

    assert_selector '#notifications-dropdown.is-hidden', visible: false
  end

  test 'toggle notifications dropdown' do
    visit_with_auth root_path, 'komagata'

    find('#notifications-bell-button').click
    assert_no_selector '#notifications-dropdown.is-hidden'
  end

  test 'toggle search modal' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: '検索').click
    assert_selector '#js-modal-search.is-shown'
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class HeaderTest < ApplicationSystemTestCase
  test 'show help dropdown' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: 'ヘルプ').click

    assert_text '受講生用ヘルプ'
    assert_text 'アドバイザー用ヘルプ'
  end

  test 'toggle notifications dropdown' do
    visit_with_auth root_path, 'komagata'

    find('#notifications-bell-button').click
    assert_selector '#notifications-bell-container.is-opened-dropdown'
  end

  test 'toggle search modal' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: '検索').click
    assert_selector '#js-modal-search.is-shown'
  end
end

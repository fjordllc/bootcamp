# frozen_string_literal: true

require 'application_system_test_case'

class HeaderTest < ApplicationSystemTestCase
  test 'show help dropdown' do
    visit_with_auth root_path, 'komagata'

    find('button.header-links__link', text: 'ヘルプ').click

    assert_text '受講生用ヘルプ'
    assert_text 'アドバイザー用ヘルプ'
  end
end

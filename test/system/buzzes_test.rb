# frozen_string_literal: true

require 'application_system_test_case'

class BuzzesTest < ApplicationSystemTestCase
  test 'mentor clicks edit button to open mentor buzzes page' do
    visit_with_auth buzzes_path, 'komagata'
    click_link '内容修正'
    assert_equal '紹介・言及記事 | FBC', title
  end

  test 'user can switch year and see buzzes grouped by month' do
    # デフォルトで最も新しい年を表示
    visit_with_auth buzzes_path, 'kimura'
    assert_selector '.selected-year', text: '2025'
    within('.buzzes-in-01') do
      assert_no_text '2025-02-01の記事'
      assert_text '2025-01-31の記事'
      assert_text '2025-01-01の記事'
      assert_no_text '2024-12-31の記事'
    end

    click_link '2024'
    assert_selector '.selected-year', text: '2024'
    within('.buzzes-in-12') do
      assert_no_text '2025-01-01の記事'
      assert_text '2024-12-31の記事'
    end
  end
end

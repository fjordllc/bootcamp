# frozen_string_literal: true

require 'application_system_test_case'

class BuzzesTest < ApplicationSystemTestCase
  test 'does not show edit button to users' do
    visit_with_auth buzzes_path, 'kimura'
    assert_no_link '内容修正'
  end

  test 'show edit button to mentors' do
    visit_with_auth buzzes_path, 'komagata'
    assert_link '内容修正'
  end

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

  test 'buzzes are shown in descending order within month' do
    visit_with_auth buzzes_path, 'kimura'
    assert_selector '.selected-year', text: '2025'
    buzzes = all('.buzzes-in-01 li').map(&:text)
    expected = %w[2025-01-31の記事 2025-01-01の記事]
    assert_equal expected, buzzes
  end

  test 'buzzes published on same day use id as tie-breaker in descending order' do
    Buzz.create!(title: '2026-02-27のbuzz-id1', url: 'https://www.example-id1.com', published_at: '2026-02-27')
    Buzz.create!(title: '2026-02-27のbuzz-id2', url: 'https://www.example-id2.com', published_at: '2026-02-27')
    visit_with_auth buzzes_path, 'kimura'
    buzzes = all('.buzzes-in-02 li').map(&:text)
    expected = %w[2026-02-27のbuzz-id2 2026-02-27のbuzz-id1]
    assert_equal expected, buzzes
  end
end

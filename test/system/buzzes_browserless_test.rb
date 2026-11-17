# frozen_string_literal: true

require 'browserless_system_test_case'

class BuzzesBrowserlessTest < BrowserlessSystemTestCase
  test 'does not show edit button to users' do
    visit_with_auth buzzes_path, 'kimura'
    assert_no_link '内容修正'
  end

  test 'show edit button to mentors' do
    visit_with_auth buzzes_path, 'komagata'
    assert_link '内容修正'
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

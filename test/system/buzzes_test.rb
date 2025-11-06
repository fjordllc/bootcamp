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
    dates = %w[2025-02-01 2025-01-31 2025-01-01 2024-12-31 2024-12-01 2024-11-30]
    # create_buzzesはapp/helper/buzz_helper.rbに定義
    create_buzzes(dates)

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
      assert_text '2024-12-01の記事'
      assert_no_text '2024-11-30の記事'
    end
    within('.buzzes-in-11') do
      assert_text '2024-11-30の記事'
      assert_no_text '2024-12-01の記事'
    end
  end

  test 'buzzes are shown in descending order within month' do
    dates = %w[2025-01-01 2025-01-10 2025-01-20 2025-01-31]
    create_buzzes(dates)

    visit_with_auth buzzes_path, 'kimura'
    assert_selector '.selected-year', text: '2025'
    buzzes = all('.buzzes-in-01 li').map(&:text)
    expected = %w[2025-01-31の記事 2025-01-20の記事 2025-01-10の記事 2025-01-01の記事]
    assert_equal expected, buzzes
  end

  test 'buzzes published on same day use id as tie-breaker in descending order' do
    create_buzz('2025-10-23', title: 'id1のbuzz')
    create_buzz('2025-10-23', title: 'id2のbuzz')
    visit_with_auth buzzes_path, 'kimura'
    buzzes = all('.buzzes-in-10 li').map(&:text)
    expected = %w[id2のbuzz id1のbuzz]
    assert_equal expected, buzzes
  end
end

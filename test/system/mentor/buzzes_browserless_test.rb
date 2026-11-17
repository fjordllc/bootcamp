# frozen_string_literal: true

require 'browserless_system_test_case'
require 'test_helper'

class Mentor::BuzzesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing buzzes' do
    visit_with_auth mentor_buzzes_path, 'machida'
    assert_equal '紹介・言及記事 | FBC', title
  end

  test 'buzzes are listed in descending order of published_at' do
    visit_with_auth mentor_buzzes_path, 'machida'
    buzz_titles = all('.admin-table__item').map { |row| row.find('td:first-child a').text }
    expected_order = %w[2025-12-31の記事 2025-02-01の記事 2025-01-31の記事 2025-01-01の記事 2024-12-31の記事]
    assert_equal expected_order, buzz_titles
  end
end

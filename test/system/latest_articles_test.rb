# frozen_string_literal: true

require 'application_system_test_case'

class LatestArticlesTest < ApplicationSystemTestCase
  test 'show listing articles' do
    visit_with_auth latest_articles_url, 'komagata'
    assert_text 'みんなのブログ'
    assert_selector '.card-list-item'
  end
end

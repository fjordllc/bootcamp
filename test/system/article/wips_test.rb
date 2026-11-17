# frozen_string_literal: true

require 'browserless_system_test_case'

class Article::WipsTest < BrowserlessSystemTestCase
  test 'show listing wip articles' do
    visit_with_auth articles_wips_path, 'komagata'
    assert_selector '.thumbnail-card__inner', count: 1
  end
end

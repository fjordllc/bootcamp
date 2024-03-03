# frozen_string_literal: true

require 'application_system_test_case'

class Article::WipsTest < ApplicationSystemTestCase
  test 'show listing wip articles' do
    visit_with_auth articles_wips_path, 'komagata'
    assert_selector '.thumbnail-card__inner', count: 1
  end
end

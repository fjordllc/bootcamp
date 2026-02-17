# frozen_string_literal: true

require 'application_system_test_case'

class Practice::CompletionTest < ApplicationSystemTestCase
  test 'hide empty submissions tab' do
    practice = practices(:practice4)
    visit_with_auth practice_path(practice), 'komagata'
    assert_no_selector 'a.page-tabs__item-link', text: '提出物'
  end

  test 'show submissions tab' do
    practice = practices(:practice1)
    visit_with_auth practice_path(practice), 'komagata'
    assert_selector 'a.page-tabs__item-link', text: '提出物'
  end
end

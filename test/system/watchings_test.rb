# frozen_string_literal: true

require 'application_system_test_case'

class WatchingTest < ApplicationSystemTestCase
  setup { login_user 'machida', 'testtest' }

  test 'show_watch' do
    visit watches_path
    assert_no_text 'テストの質問1'
    question = questions(:question3)
    visit question_path(question)
    wait_for_vuejs
    find('#watch-button').click
    visit watches_path
    assert_text 'テストの質問1'
  end
end

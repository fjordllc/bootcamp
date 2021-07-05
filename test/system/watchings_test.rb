# frozen_string_literal: true

require 'application_system_test_case'

class WatchingTest < ApplicationSystemTestCase
  test 'show my watch list' do
    visit_with_auth watches_path, 'hajime'
    assert_no_text 'テストの質問1'
    question = questions(:question3)
    visit question_path(question)
    wait_for_vuejs
    find('#watch-button').click
    visit watches_path
    assert_text 'テストの質問1'
  end

  test 'watch index checkbox test' do
    login_user 'kimura', 'testtest'
    visit watches_path
    assert_no_selector '.thread-list-item__option'
    find(:css, '#spec-edit-mode').set(true)
    wait_for_vuejs
    assert_selector '.thread-list-item__option'
  end

  test 'watch index page watchbutton test' do
    login_user 'kimura', 'testtest'
    report = reports(:report1)
    visit report_path(report)
    wait_for_vuejs
    assert_text 'Watch中'
    visit watches_path
    assert_text '作業週1日目'
    find(:css, '#spec-edit-mode').set(true)
    assert_selector '.thread-list-item__option'
    first('#watch-button').click
    wait_for_vuejs
    assert_no_text '作業週1日目'
    visit report_path(report)
    assert_text 'Watch'
  end
end

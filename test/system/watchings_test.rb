# frozen_string_literal: true

require 'application_system_test_case'

class WatchingTest < ApplicationSystemTestCase
  setup { login_user 'hajime', 'testtest' }

  test 'show my watch list' do
    visit watches_path
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
    uncheck '編集'
    assert_no_text 'Watchを外す'
    check '編集'
    assert_text 'Watchを外す'
  end

  test 'watch index page watchbutton test' do
    login_user 'kimura', 'testtest'
    report = reports(:report1)
    visit report_path(report)
    assert_text 'Watch中'
    visit watches_path
    assert_text '作業週1日目'
    check '編集'
    assert_text 'Watchを外す'
    first('#watch-button').click
    wait_for_vuejs
    assert_no_text '作業週1日目'
    visit report_path(report)
    assert_text 'Watchする'
  end
end

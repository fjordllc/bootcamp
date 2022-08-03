# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::WatchesTest < ApplicationSystemTestCase
  test 'show current_user watches when current_user is student' do
    visit_with_auth '/current_user/watches', 'kimura'
    assert_equal 'Watch中 | FBC', title
  end

  # 画面上では更新の完了がわからないため、やむを得ずsleepする
  # 注意）安易に使用しないこと!! https://bootcamp.fjord.jp/pages/use-assert-text-instead-of-wait-for-vuejs
  def wait_for_watch_change
    sleep 1
  end

  # 下記3つのtestは/watches削除に伴い、WatchingTestより転記し修正した
  test 'show my watch list' do
    visit_with_auth '/current_user/watches', 'hajime'
    assert_no_text 'テストの質問1'
    question = questions(:question3)
    visit question_path(question)
    find('#watch-button').click
    wait_for_watch_change
    visit '/current_user/watches'
    assert_text 'テストの質問1'
  end

  test 'watch index checkbox test' do
    login_user 'kimura', 'testtest'
    visit '/current_user/watches'
    assert_no_selector '.card-list-item__option'
    find(:css, '#spec-edit-mode').set(true)
    assert_selector '.card-list-item__option'
  end

  test 'watch index page watchbutton test' do
    login_user 'kimura', 'testtest'
    report = reports(:report1)
    visit report_path(report)
    assert_text 'Watch中'
    visit '/current_user/watches'
    assert_text '作業週1日目'
    find(:css, '#spec-edit-mode').set(true)
    assert_selector '.card-list-item__option'
    first('#watch-button').click
    wait_for_watch_change
    assert_no_text '作業週1日目'
    visit report_path(report)
    assert_text 'Watch'
  end

  test 'list watching practice and another' do
    visit_with_auth '/current_user/watches', 'mentormentaro'

    assert_text 'OS X Mountain Lionをクリーンインストールする'
    assert_text 'description...'
    assert_no_text 'mentormentaro'

    assert_text 'test1'
    assert_text 'testtest'
    assert_text 'komagata'
  end
end

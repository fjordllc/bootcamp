# frozen_string_literal: true

require 'application_system_test_case'

class Notification::WatchesTest < ApplicationSystemTestCase
  test '日報作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現' do
    watches(:report1_watch_kimura)
    # コメントを投稿しても自動的にウォッチがONになる
    visit_with_auth "/reports/#{reports(:report1).id}", 'machida'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'いい日報ですね。')
    end
    click_button 'コメントする'
    wait_for_vuejs
    logout

    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'コメントありがとうございます。')
    end
    click_button 'コメントする'
    wait_for_vuejs
    logout

    login_user 'kimura', 'testtest'
    open_notification
    assert_equal "komagataさんの【 「#{reports(:report1).title}」の日報 】にkomagataさんがコメントしました。",
                 notification_message

    login_user 'machida', 'testtest'
    open_notification

    assert_equal "komagataさんの【 「#{reports(:report1).title}」の日報 】にkomagataさんがコメントしました。",
                 notification_message
  end

  test '質問作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現' do
    watches(:question1_watch_kimura)
    # 質問に回答しても自動でウォッチがつく
    visit_with_auth "/questions/#{questions(:question1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'Vimチュートリアルがおすすめです。')
    end
    click_button 'コメントする'
    wait_for_vuejs
    logout

    visit_with_auth "/questions/#{questions(:question1).id}", 'machida'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: '質問へのご回答ありがとうございます。')
    end
    click_button 'コメントする'
    wait_for_vuejs
    logout

    login_user 'kimura', 'testtest'
    open_notification
    assert_equal "machidaさんの【 「#{questions(:question1).title}」のQ&A 】にmachidaさんがコメントしました。",
                 notification_message

    login_user 'komagata', 'testtest'
    open_notification
    assert_equal "machidaさんの【 「#{questions(:question1).title}」のQ&A 】にmachidaさんがコメントしました。",
                 notification_message
  end
end

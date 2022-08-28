# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AnswersTest < ApplicationSystemTestCase
  setup do
    @notice_text = 'komagataさんから回答がありました。'
    @notice_best_answer_text = 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test "receive a notification when I got my question's answer" do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'reduceも使ってみては？')
    end
    click_button 'コメントする'
    assert_text '回答を投稿しました！'

    visit_with_auth '/notifications', 'sotugyou'

    within first('.card-list-item.is-unread') do
      assert_text @notice_text
    end

    visit_with_auth '/', 'komagata'
    refute_text @notice_text
  end

  test 'notify watchers of best answer' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'sotugyou'
    accept_confirm do
      click_button 'ベストアンサーにする'
    end

    # Watcherに通知される
    visit_with_auth '/notifications?status=unread', 'kimura'
    within first('.card-list-item.is-unread') do
      assert_text @notice_best_answer_text
    end

    # Watchしていない回答者には通知されない
    visit_with_auth '/notifications?status=unread', 'komagata'
    within first('.card-list-item.is-unread') do
      assert_no_text @notice_best_answer_text
    end

    # 質問者には通知されない
    visit_with_auth '/notifications?status=unread', 'sotugyou'
    within first('.card-list-item.is-unread') do
      assert_no_text @notice_best_answer_text
    end
  end
end

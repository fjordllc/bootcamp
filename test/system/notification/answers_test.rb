# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::AnswersTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'komagataさんから回答がありました。'
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

    assert_user_has_notification(user: users(:sotugyou), kind: Notification.kinds[:answered], text: @notice_text)
    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:answered], text: @notice_text)
  end
end

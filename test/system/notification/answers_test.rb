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

    sotugyou = users(:sotugyou)
    sotugyou_notifications = Notification.where(user: sotugyou, kind: Notification.kinds[:answered])
    assert sotugyou_notifications.any? { |n| n.message.include?(@notice_text) }, 'sotugyou should have answered notification'

    komagata = users(:komagata)
    komagata_notifications = Notification.where(user: komagata, kind: Notification.kinds[:answered])
    assert_not komagata_notifications.any? { |n| n.message.include?(@notice_text) }, 'komagata should not have answered notification'
  end
end

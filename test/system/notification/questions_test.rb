# frozen_string_literal: true

require 'notification_system_test_case'

# 通知する条件（WIP、公開、更新、削除）は test/models/question_callbacks_test.rb と
# test/models/question_test.rb で確かめる。
class Notification::QuestionsTest < NotificationSystemTestCase
  include ActiveJob::TestHelper
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_kind = Notification.kinds['came_question']
    @notified_count = Notification.where(kind: @notice_kind).size
    @mentor_count = User.mentor.size

    mock_openai_chat_completion
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'mentor receive notification when question is posted' do
    visit_with_auth '/questions/new', 'hatsuno'
    within 'form[name=question]' do
      fill_in('question[title]', with: 'メンターに質問！！')
      fill_in('question[description]', with: '通知行ってますか？')
    end

    perform_enqueued_jobs do
      click_button '登録する'
      assert_text '質問を作成しました。'
    end

    assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_question], text: 'hatsunoさんから質問「メンターに質問！！」が投稿されました。')

    assert_equal @notified_count + @mentor_count, Notification.where(kind: @notice_kind).size
  end
end

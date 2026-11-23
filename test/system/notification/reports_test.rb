# frozen_string_literal: true

require 'notification_system_test_case'

# 通知する条件（初めての日報、連続のnegative、メンション、削除）は test/models/first_report_notifier_test.rb、
# test/models/report_notifier_test.rb、test/models/report_callbacks_test.rb、test/models/concerns/mentioner_test.rb で確かめる。
class Notification::ReportsTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify when WIP report submitted' do
    Report.all.find_each(&:destroy)

    visit_with_auth '/reports/new', 'kensyu'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end
    within('.learning-time__started-at') do
      select '07'
      select '30'
    end
    within('.learning-time__finished-at') do
      select '08'
      select '30'
    end

    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'

    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:first_report], text: 'kensyuさんがはじめての日報を書きました！')

    visit_with_auth "/users/#{users(:kensyu).id}/reports", 'kensyu'
    click_link 'test title'
    click_link '内容修正'
    click_button '提出'
    assert_text '日報を保存しました。'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:first_report], text: 'kensyuさんがはじめての日報を書きました！')
  end
end

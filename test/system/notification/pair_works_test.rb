# frozen_string_literal: true

require 'notification_system_test_case'

# 公開、ペアの変更、日程の変更、取り消しの通知は test/integration/pair_work_notifications_test.rb で確かめる。
class Notification::PairWorksTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'watcher receive notification when pair_work is matched' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      visit_with_auth '/pair_works/new', 'kimura'
      within 'form[name=pair_work]' do
        fill_in 'pair_work[title]', with: 'テストのペアワーク募集'
        fill_in 'pair_work[description]', with: 'テストのペアワーク募集です。'
        within '.form-table' do
          check 'schedule_ids_202503030000', allow_label_click: true
        end
      end
      click_button '登録する'
      assert_selector '.flash-message.js-toast[data-message="ペアワークを作成しました。"]'
      assert_text 'Watch中'
      logout

      visit_with_auth pair_works_path(target: 'not_solved'), 'mentormentaro'
      click_on 'テストのペアワーク募集'
      assert_text 'Watch中'
      within '.a-table' do
        accept_alert do
          find_button(id: '2025-03-03T00:00:00+09:00').click
        end
      end
      assert_selector '.flash-message.js-toast[data-message="ペアが確定しました。"]'

      assert_user_has_notification(user: users(:kimura), kind: Notification.kinds[:matching_pair_work],
                                   text: 'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがmentormentaroさんに決定しました。')
      assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:matching_pair_work],
                                   text: 'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがあなたに決定しました。')
    end
  end
end

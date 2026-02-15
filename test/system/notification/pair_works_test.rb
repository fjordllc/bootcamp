# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::PairWorksTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'mentor receive notification when pair_work is posted' do
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
      assert_text 'ペアワークを作成しました。'

      assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_pair_work], text: 'kimuraさんからペアワーク依頼「テストのペアワーク募集」が投稿されました。')
    end
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
      assert_text 'ペアワークを作成しました。'
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
      assert_text 'ペアが確定しました。'

      assert_user_has_notification(user: users(:kimura), kind: Notification.kinds[:matching_pair_work],
                                   text: 'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがmentormentaroさんに決定しました。')
      assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:matching_pair_work],
                                   text: 'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがあなたに決定しました。')
    end
  end

  test 'notify when a WIP pair_work is published' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      visit_with_auth '/pair_works/new', 'kimura'
      within 'form[name=pair_work]' do
        fill_in 'pair_work[title]', with: 'WIPで保存時は通知が飛ばない'
        fill_in 'pair_work[description]', with: 'WIPで保存時は通知が飛ばない'
        within '.form-table' do
          check 'schedule_ids_202503030000', allow_label_click: true
        end
      end
      click_button 'WIP'
      assert_text 'ペアワークをWIPとして保存しました。'
      assert_user_has_no_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_pair_work],
                                      text: 'WIPで保存時は通知が飛ばない')

      within 'form[name=pair_work]' do
        fill_in 'pair_work[title]', with: '公開された時に通知が飛ぶ'
        fill_in 'pair_work[description]', with: '公開された時に通知が飛ぶ'
      end
      click_button 'ペアワークを公開'
      assert_text 'ペアワークを更新しました。'

      assert_user_has_notification(user: users(:mentormentaro), kind: Notification.kinds[:came_pair_work], text: '公開された時に通知が飛ぶ')
    end
  end
end

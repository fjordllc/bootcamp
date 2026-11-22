# frozen_string_literal: true

require 'test_helper'

class PairWorkNotificationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'mentors are notified when a pair work is published' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      login 'kimura'

      create_pair_work(title: 'WIPで保存時は通知が飛ばない', commit: 'WIP')
      pair_work = PairWork.find_by!(title: 'WIPで保存時は通知が飛ばない')
      assert_empty notification_messages(:mentormentaro, :came_pair_work, pair_work)

      perform_enqueued_jobs do
        patch pair_work_path(pair_work), params: { pair_work: { title: '公開された時に通知が飛ぶ' }, commit: 'ペアワークを公開' }
      end
      assert_equal ['kimuraさんからペアワーク依頼「公開された時に通知が飛ぶ」が投稿されました。'],
                   notification_messages(:mentormentaro, :came_pair_work, pair_work)
    end
  end

  test 'watchers are notified when a pair is matched and when the match is canceled' do
    travel_to Time.zone.local(2025, 3, 2, 0, 0, 0) do
      login 'kimura'
      create_pair_work(title: 'テストのペアワーク募集', commit: '登録する')
      pair_work = PairWork.find_by!(title: 'テストのペアワーク募集')

      login 'mentormentaro'
      perform_enqueued_jobs do
        post pair_work_reservations_path(pair_work), params: { pair_work: { reserved_at: '2025-03-03T00:00:00+09:00' } }
      end
      assert_includes notification_messages(:kimura, :matching_pair_work, pair_work),
                      'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがmentormentaroさんに決定しました。'
      assert_includes notification_messages(:mentormentaro, :matching_pair_work, pair_work),
                      'kimuraさんのペアワーク【 テストのペアワーク募集 】のペアがあなたに決定しました。'

      perform_enqueued_jobs do
        delete pair_work_reservations_path(pair_work)
      end
      %i[kimura komagata].each do |watcher|
        assert_includes notification_messages(watcher, :cancel_pair_work, pair_work),
                        'ペアワーク「テストのペアワーク募集」のペア確定が取り消されました。'
      end
    end
  end

  test 'creator and past buddy are notified when the pair is changed' do
    pair_work = pair_works(:pair_work2)

    travel_to Time.zone.local(2025, 1, 1, 0, 0, 0) do
      login 'mentormentaro'
      perform_enqueued_jobs do
        patch pair_work_reservations_path(pair_work), params: { pair_work: { reserved_at: '2025-01-02T01:00:00+09:00' } }
      end
    end

    %i[kimura sotugyou].each do |receiver|
      assert_includes notification_messages(receiver, :rematching_pair_work, pair_work),
                      'ペアワーク「ペア確定済みのペアワークです(タイトル)」のペアがmentormentaroに変更されました。'
    end
  end

  test 'creator is notified when the pair work is rescheduled' do
    pair_work = pair_works(:pair_work4)

    travel_to Time.zone.local(2025, 1, 1, 0, 0, 0) do
      login 'komagata'
      perform_enqueued_jobs do
        patch pair_work_reservations_path(pair_work), params: { pair_work: { reserved_at: '2025-01-03T01:00:00+09:00' } }
      end
    end

    assert_includes notification_messages(:kimura, :reschedule_pair_work, pair_work),
                    'ペアワーク「日程変更動作確認用のペアワークです。」の日程が2025年01月03日(金) 01:00に変更されました。'
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end

  def create_pair_work(title:, commit:)
    perform_enqueued_jobs do
      post pair_works_path, params: {
        pair_work: { title:, description: "#{title}です。", schedules_attributes: [{ proposed_at: '2025-03-03T00:00:00+09:00' }] },
        commit:
      }
    end
  end

  def notification_messages(login_name, kind, pair_work)
    Notification.where(user: users(login_name), kind:, link: "/pair_works/#{pair_work.id}").map(&:message)
  end
end

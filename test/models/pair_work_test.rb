# frozen_string_literal: true

require 'test_helper'

class PairWorkTest < ActiveSupport::TestCase
  test '.by_target' do
    solved_pair_work = pair_works(:pair_work2)
    not_solved_pair_work = pair_works(:pair_work1)
    assert_includes PairWork.by_target('solved'), solved_pair_work
    assert_not_includes PairWork.by_target('solved'), not_solved_pair_work

    assert_includes PairWork.by_target('not_solved'), not_solved_pair_work
    assert_not_includes PairWork.by_target('not_solved'), solved_pair_work

    assert_includes PairWork.by_target(nil), solved_pair_work
    assert_includes PairWork.by_target(nil), not_solved_pair_work
  end

  test '.generate_pair_works_property' do
    solved_pair_works_property = PairWork.generate_pair_works_property('solved')
    assert_equal 'ペア確定済みのペアワーク', solved_pair_works_property.title
    assert_equal 'ペア確定済みのペアワークはありません。', solved_pair_works_property.empty_message

    not_solved_pair_works_property = PairWork.generate_pair_works_property('not_solved')
    assert_equal '募集中のペアワーク', not_solved_pair_works_property.title
    assert_equal '募集中のペアワークはありません。', not_solved_pair_works_property.empty_message

    all_pair_works_property = PairWork.generate_pair_works_property(nil)
    assert_equal '全てのペアワーク', all_pair_works_property.title
    assert_equal 'ペアワークはありません。', all_pair_works_property.empty_message
  end

  test '#generate_notice_message' do
    wip_pair_work = pair_works(:pair_work3)
    assert_equal 'ペアワークをWIPとして保存しました。', wip_pair_work.generate_notice_message(:create)
    assert_equal 'ペアワークをWIPとして保存しました。', wip_pair_work.generate_notice_message(:update)

    published_pair_work = pair_works(:pair_work1)
    assert_equal 'ペアワークを作成しました。', published_pair_work.generate_notice_message(:create)
    assert_equal 'ペアワークを更新しました。', published_pair_work.generate_notice_message(:update)
  end

  test '.unsolved_badge' do
    assert_equal 1, PairWork.unsolved_badge(current_user: users(:komagata))

    assert_nil PairWork.unsolved_badge(current_user: users(:hatsuno))
  end

  test '.update_permission?' do
    admin = users(:komagata)
    mentor = users(:mentormentaro)
    matching_params = { buddy_id: 1, reserved_at: '2025-01-20' }
    update_params = {
      title: 'タイトル', description: '詳細',
      practice_id: 1, channel: 'チャンネル', schedules_attributes: {}
    }

    assert PairWork.update_permission?(admin, update_params)
    assert_not PairWork.update_permission?(mentor, update_params)

    assert PairWork.update_permission?(admin, matching_params)
    assert PairWork.update_permission?(mentor, matching_params)
  end

  test '.matching_params?' do
    matching_params = { buddy_id: 1, reserved_at: '2025-01-20' }
    update_params = {
      title: 'タイトル', description: '詳細',
      practice_id: 1, channel: 'チャンネル', schedules_attributes: {}
    }
    assert PairWork.matching_params?(matching_params)
    assert_not PairWork.matching_params?(update_params)
  end

  test '.upcoming_pair_works' do
    user = users(:hajime)

    travel_to Time.zone.local(2025, 1, 15, 12, 0, 0) do
      pair_work_template = {
        user:,
        title: 'ペアが確定していて、近日開催されるペアワーク',
        description: 'ペアが確定していて、近日開催されるペアワーク',
        buddy: users(:komagata),
        channel: 'ペアワーク・モブワーク1',
        wip: false
      }
      upcoming_pair_work_tomorrow = PairWork.create!(pair_work_template.merge(
                                                       reserved_at: Time.current.beginning_of_day + 1.day,
                                                       schedules_attributes: [{ proposed_at: Time.current.beginning_of_day + 1.day }]
                                                     ))
      upcoming_pair_work_day_after_tomorrow = PairWork.create!(pair_work_template.merge(
                                                                 reserved_at: Time.current.beginning_of_day + 2.days,
                                                                 schedules_attributes: [{ proposed_at: Time.current.beginning_of_day + 2.days }]
                                                               ))
      assert_includes PairWork.upcoming_pair_works(user), upcoming_pair_work_tomorrow
      assert_includes PairWork.upcoming_pair_works(user), upcoming_pair_work_day_after_tomorrow

      held_today_pair_work = PairWork.create!(pair_work_template.merge(
                                                reserved_at: Time.current.beginning_of_day,
                                                schedules_attributes: [{ proposed_at: Time.current.beginning_of_day }]
                                              ))
      assert_not_includes PairWork.upcoming_pair_works(user), held_today_pair_work

      unrelated_pair_work = pair_works(:pair_work2)
      assert_not_includes PairWork.upcoming_pair_works(user), unrelated_pair_work
    end
  end

  test '.not_held' do
    not_held_pair_work = PairWork.create!({
                                            user: users(:kimura),
                                            title: 'ペア確定したけどまだ実施されてないペアワーク',
                                            description: 'ペア確定したけどまだ実施されてないペアワーク',
                                            buddy_id: users(:komagata),
                                            channel: 'ペアワーク・モブワーク1',
                                            wip: false,
                                            reserved_at: Time.current.beginning_of_day + 1.day,
                                            schedules_attributes: [{ proposed_at: Time.current.beginning_of_day + 1.day }]
                                          })
    not_solved_pair_work = pair_works(:pair_work1)
    wip_pair_work = pair_works(:pair_work3)

    held_on_pair_work = pair_works(:pair_work2)

    assert_includes PairWork.not_held, not_held_pair_work
    assert_includes PairWork.not_held, not_solved_pair_work
    assert_includes PairWork.not_held, wip_pair_work

    assert_not_includes PairWork.not_held, held_on_pair_work
  end

  test '#solved?' do
    solved_pair_work = pair_works(:pair_work2)
    assert solved_pair_work.solved?

    not_solved_pair_work = pair_works(:pair_work1)
    assert_not not_solved_pair_work.solved?
  end

  test '#important?' do
    not_solved_pair_work = pair_works(:pair_work1)
    assert not_solved_pair_work.important?

    not_solved_pair_work.comments.create!(
      user: users(:komagata),
      description: 'コメント'
    )
    assert_not not_solved_pair_work.important?

    solved_pair_work = pair_works(:pair_work2)
    assert_not solved_pair_work.important?
  end
end

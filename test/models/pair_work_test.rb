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

  test '.generate_notice_message' do
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
    valid_params = { buddy_id: 1, reserved_at: 1 }
    invalid_params = { buddy_id: 1, reserved_at: 1, title: '不正に改変しようとしているtitle', description: '不正に改変しようとしているdescription' }
    assert PairWork.update_permission?(users(:mentormentaro), valid_params)
    assert_not PairWork.update_permission?(users(:mentormentaro), invalid_params)
  end

  test '.upcoming_pair_works' do
    user = users(:hajime)

    pair_work_attributes = {
      user:,
      title: 'ペアが確定していて、近日開催されるペアワーク',
      description: 'ペアが確定していて、近日開催されるペアワーク',
      buddy_id: users(:komagata),
      channel: 'ペアワーク・モブワーク1',
      wip: false
    }
    upcoming_pair_work_today = PairWork.create!(pair_work_attributes.merge(
                                                  reserved_at: Time.current.beginning_of_day,
                                                  schedules_attributes: [{ proposed_at: Time.current.beginning_of_day }]
                                                ))
    upcoming_pair_work_tomorrow = PairWork.create!(pair_work_attributes.merge(
                                                     reserved_at: Time.current.beginning_of_day + 1.day,
                                                     schedules_attributes: [{ proposed_at: Time.current.beginning_of_day + 1.day }]
                                                   ))
    upcoming_pair_work_day_after_tomorrow = PairWork.create!(pair_work_attributes.merge(
                                                               reserved_at: Time.current.beginning_of_day + 2.days,
                                                               schedules_attributes: [{ proposed_at: Time.current.beginning_of_day + 2.days }]
                                                             ))

    assert_includes PairWork.upcoming_pair_works(user), upcoming_pair_work_today
    assert_includes PairWork.upcoming_pair_works(user), upcoming_pair_work_tomorrow
    assert_includes PairWork.upcoming_pair_works(user), upcoming_pair_work_day_after_tomorrow

    unrelated_pair_work = pair_works(:pair_work2)
    assert_not_includes PairWork.upcoming_pair_works(user), unrelated_pair_work
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

  test '#solved? returns true when reserved_at is set' do
    solved_pair_work = pair_works(:pair_work2)
    assert solved_pair_work.solved?
  end

  test '#solved? returns false when reserved_at is nil' do
    not_solved_pair_work = pair_works(:pair_work1)
    assert_not not_solved_pair_work.solved?
  end

  test '#important? returns true when comments are blank and not solved' do
    not_solved_pair_work = pair_works(:pair_work1)
    assert not_solved_pair_work.important?
  end

  test '#important? returns false when there are comments' do
    not_solved_pair_work = pair_works(:pair_work1)
    not_solved_pair_work.comments.create!(
      user: users(:komagata),
      description: 'コメント'
    )
    assert_not not_solved_pair_work.important?
  end

  test '#important? returns false when solved' do
    solved_pair_work = pair_works(:pair_work2)
    assert_not solved_pair_work.important?
  end
end

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
    wip_pair_work = PairWork.create!(
      title: 'wipのペアワーク',
      description: 'wipのペアワーク',
      user: users(:kimura),
      channel: 'ペアワーク・モブワーク1',
      wip: true,
      schedules_attributes: [{ proposed_at: Time.current + 1.day }]
    )
    assert_equal 'ペアワークをWIPとして保存しました。', wip_pair_work.generate_notice_message(:create)
    assert_equal 'ペアワークをWIPとして保存しました。', wip_pair_work.generate_notice_message(:update)

    published_pair_work = pair_works(:pair_work1)
    assert_equal 'ペアワークを作成しました。', published_pair_work.generate_notice_message(:create)
    assert_equal 'ペアワークを更新しました。', published_pair_work.generate_notice_message(:update)
  end
end

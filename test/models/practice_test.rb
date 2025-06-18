# frozen_string_literal: true

require 'test_helper'

class PracticeTest < ActiveSupport::TestCase
  fixtures :learnings, :practices, :users

  test '#started_or_submitted_learnings' do
    started_or_submitted_learnings = practices(:practice3).started_or_submitted_learnings

    started_or_submitted_learnings.each do |learning|
      assert_includes %w[started submitted], learning.status
    end
  end

  test '#status(user)' do
    assert_equal \
      practices(:practice1).status(users(:komagata)),
      'started'

    assert_equal \
      practices(:practice1).status(users(:machida)),
      'unstarted'
  end

  test '#status_by_learnings(learnings)' do
    learnings = users(:komagata).learnings

    assert_equal practices(:practice1).status_by_learnings(learnings), 'started'
    assert_equal practices(:practice2).status_by_learnings(learnings), 'complete'
    assert_equal practices(:practice3).status_by_learnings(learnings), 'unstarted'
    assert_equal practices(:practice4).status_by_learnings(learnings), 'submitted'
    assert_equal practices(:practice5).status_by_learnings(learnings), 'unstarted'
  end

  test '#exists_learning?(user)' do
    assert practices(:practice1).exists_learning?(users(:komagata))
    assert_not practices(:practice1).exists_learning?(users(:machida))
  end

  test '.save_learning_minute_statistics' do
    LearningMinuteStatistic.delete_all
    assert LearningMinuteStatistic.count.zero?

    Practice.save_learning_minute_statistics

    practice_ids = Practice.joins(:reports).merge(Report.not_wip).distinct.pluck(:id)
    assert_equal practice_ids.size, LearningMinuteStatistic.count
  end

  test '#category' do
    practice = practices(:practice1)
    course = courses(:course1)
    category = categories(:category2)

    assert_equal category, practice.category(course)
  end

  test 'source_id_cannot_be_self validation prevents self-reference' do
    practice = practices(:practice1)
    practice.source_id = practice.id

    assert_not practice.valid?
    assert_includes practice.errors[:source_id], 'cannot reference itself'
  end

  test 'source_id_cannot_be_self validation allows nil source_id' do
    practice = practices(:practice1)
    practice.source_id = nil

    assert practice.valid?
  end

  test 'source_id_cannot_be_self validation allows different practice reference' do
    practice1 = practices(:practice1)
    practice2 = practices(:practice2)
    practice1.source_id = practice2.id

    assert practice1.valid?
  end
end

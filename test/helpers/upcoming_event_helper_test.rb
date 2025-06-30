# frozen_string_literal: true

require 'test_helper'

class UpcomingEventHelperTest < ActionView::TestCase
  include Sorcery::Controller::InstanceMethods
  include Sorcery::TestHelpers::Rails::Controller
  test 'scheduled_on_pair_works' do
    user = users(:kimura)
    login_user(user)

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

    assert_includes scheduled_on_pair_works(:today), upcoming_pair_work_today
    assert_includes scheduled_on_pair_works(:tomorrow), upcoming_pair_work_tomorrow
    assert_includes scheduled_on_pair_works(:day_after_tomorrow), upcoming_pair_work_day_after_tomorrow
  end
end

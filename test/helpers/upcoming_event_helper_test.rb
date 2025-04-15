# frozen_string_literal: true

require 'test_helper'

class UpcomingEventHelperTest < ActionView::TestCase
  include Sorcery::Controller::InstanceMethods
  include Sorcery::TestHelpers::Rails::Controller

  test 'scheduled_on_pair_works' do
    login_user(users(:kimura))
    upcoming_pair_work = PairWork.create!(
      title: '相手が確定していて、今日行われるペアワーク',
      description: '相手が確定していて、今日行われるペアワーク',
      user: users(:kimura),
      reserved_at: Time.current.beginning_of_day,
      buddy_id: users(:komagata),
      channel: 'ペアワーク・モブワーク1',
      wip: false
    )
    upcoming_pair_work_second = PairWork.create!(
      title: '相手が確定していて、今日行われるペアワーク2',
      description: '相手が確定していて、今日行われるペアワーク2',
      user: users(:kimura),
      reserved_at: Time.current.beginning_of_day,
      buddy_id: users(:komagata),
      channel: 'ペアワーク・モブワーク1',
      wip: false
    )
    upcoming_pair_works = []
    upcoming_pair_works << upcoming_pair_work << upcoming_pair_work_second
    assert_equal upcoming_pair_works, scheduled_on_pair_works(:today)
  end
end

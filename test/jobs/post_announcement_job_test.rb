# frozen_string_literal: true

require 'test_helper'

class PostAnnouncementJobTest < ActiveJob::TestCase
  teardown do
    ActionMailer::Base.deliveries.clear
    AbstractNotifier::Testing::Driver.deliveries.clear
  end

  test '#perform' do
    announcement = announcements(:announcement1)
    receivers = [users(:machida), users(:adminonly), users(:sotugyou_with_job)]

    assert_difference [-> { ActionMailer::Base.deliveries.count }, -> { AbstractNotifier::Testing::Driver.deliveries.count }], 3 do
      perform_enqueued_jobs do
        PostAnnouncementJob.perform_later(announcement, receivers)
      end
    end

    assert_performed_jobs 1
  end
end

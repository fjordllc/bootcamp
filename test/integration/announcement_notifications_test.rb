# frozen_string_literal: true

require 'test_helper'

class AnnouncementNotificationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    post user_sessions_path, params: { user: { login: 'machida', password: 'testtest' } }
  end

  test 'announcement for students notifies the active users, admins and mentors' do
    announcement = create_announcement(title: '現役生にのみお知らせtest', target: 'students')

    assert_equal 'お知らせ「現役生にのみお知らせtest」', notifications(announcement).first.message
    assert_notified announcement, to: %i[kimura komagata mentormentaro], not_to: %i[sotugyou advijirou yameo kensyu machida]
  end

  test 'announcement for job seekers notifies the job seekers, admins and mentors' do
    announcement = create_announcement(title: '就活希望者のみお知らせします', target: 'job_seekers')

    assert_notified announcement, to: %i[jobseeker komagata mentormentaro], not_to: %i[kimura machida]
  end

  test 'WIP announcement notifies nobody' do
    announcement = create_announcement(title: 'WIPのお知らせ', target: 'all', commit: 'WIP')

    assert announcement.wip?
    assert_empty notifications(announcement)
  end

  private

  def create_announcement(title:, target:, commit: '作成')
    perform_enqueued_jobs do
      post announcements_path, params: { announcement: { title:, description: '内容test', target: }, commit: }
    end
    Announcement.find_by!(title:)
  end

  def notifications(announcement)
    Notification.where(kind: :announced, link: "/announcements/#{announcement.id}")
  end

  def assert_notified(announcement, to:, not_to:)
    receivers = notifications(announcement).map(&:user)
    to.each { |name| assert_includes receivers, users(name) }
    not_to.each { |name| assert_not_includes receivers, users(name) }
  end
end

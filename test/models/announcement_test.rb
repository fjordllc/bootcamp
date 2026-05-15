# frozen_string_literal: true

require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  test '.copy_announcement(announcement_id)' do
    announcement = Announcement.create!(
      user_id: users(:kimura).id,
      title: 'お知らせのタイトルです',
      description: 'お知らせの内容です',
      target: 0
    )
    copied_announcement = Announcement.copy_announcement(announcement.id)

    assert_equal copied_announcement.title, announcement.title
    assert_equal copied_announcement.description, announcement.description
    assert_equal copied_announcement.target, announcement.target
  end

  test '.copy_template_by_resource(template_file, params = {})' do
    event = events(:event1)
    template = MessageTemplate.load('event_announcements.yml', params: { event: })
    announcement = Announcement.new(title: template['title'], description: template['description'])
    announcement_based_template = Announcement.copy_template_by_resource('event_announcements.yml', event:)

    assert_equal announcement_based_template.title, announcement.title
    assert_equal announcement_based_template.description, announcement.description
  end
end

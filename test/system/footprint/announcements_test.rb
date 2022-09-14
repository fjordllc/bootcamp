# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @announcement = announcements(:announcement1)
  end

  test 'should be create footprint in /announcements/:id' do
    visit_with_auth announcement_path(@announcement), 'kimura'
    assert_css '.a-user-icon.is-kimura'
  end

  test 'should not footpoint with my own announcement' do
    visit_with_auth announcement_path(@announcement), 'komagata'
    assert_no_css '.a-user-icon.is-komagata'
  end

  test 'show link if there are more than ten footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @announcement.id,
        footprintable_type: 'Announcement'
      )
    end

    visit_with_auth announcement_path(@announcement), 'komagata'
    assert_text 'その他1人'
  end

  test 'has no link if there are less than ten footprints' do
    user_data = User.unhibernated.unretired.last(10)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @announcement.id,
        footprintable_type: 'Announcement'
      )
    end

    visit_with_auth announcement_path(@announcement), 'komagata'
    assert_no_text 'その他'
  end

  test 'click on the link to view the rest of footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @announcement.id,
        footprintable_type: 'Announcement'
      )
    end

    visit_with_auth announcement_path(@announcement), 'komagata'
    assert_text 'その他1人'

    find('.user-icons__more', text: 'その他1人').click
    assert_no_text 'その他1人'
  end
end

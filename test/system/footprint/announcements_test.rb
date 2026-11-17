# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @announcement = announcements(:announcement1)
  end

  test 'should not footpoint with my own announcement' do
    visit_with_auth announcement_path(@announcement), 'komagata'
    assert_no_css '.a-user-icon.is-komagata'
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

    find('.user-icons__more').click
    assert_no_css '.user-icons__more'
  end
end

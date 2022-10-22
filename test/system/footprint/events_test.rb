# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:event1)
  end

  test 'should be create footprint in /events/:id' do
    visit_with_auth event_path(@event), 'sotugyou'
    assert_css '.a-user-icon.is-sotugyou'
  end

  test 'should not footpoint with my own regular event' do
    visit_with_auth event_path(@event), 'komagata'
    assert_no_css '.a-user-icon.is-komagata'
  end

  test 'show link if there are more than ten footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @event.id,
        footprintable_type: "Event"
      )
    end

    visit_with_auth event_path(@event), 'komagata'
    assert_text 'その他1人'
  end

  test 'has no link if there are less than ten footprints' do
    user_data = User.unhibernated.unretired.last(10)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @event.id,
        footprintable_type: "Event"
      )
    end

    visit_with_auth event_path(@event), 'komagata'
    assert_no_text 'その他'
  end

  test 'click on the link to view the rest of footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @event.id,
        footprintable_type: "Event"
      )
    end

    visit_with_auth event_path(@event), 'komagata'
    assert_text 'その他1人'

    find('.page-content-prev-next__item-link', text: 'その他1人').click
    assert_no_text 'その他1人'
  end
end

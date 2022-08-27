# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::RegularEventsTest < ApplicationSystemTestCase
  test 'should be create footprint in /regular_events/:id' do
    regular_event = users(:komagata).regular_events.first
    visit_with_auth regular_event_path(regular_event), 'sotugyou'
    assert_text '見たよ'
    assert page.has_css?('.a-user-icon.is-sotugyou')
  end

  test 'should not footpoint with my own regular event' do
    regular_event = users(:sotugyou).regular_events.first
    visit_with_auth regular_event_path(regular_event), 'sotugyou'
    assert_no_text '見たよ'
    assert_not page.has_css?('.a-user-icon.is-sotugyou')
  end

  test 'show link if there are more than ten footprints' do
    regular_event = users(:komagata).regular_events.first
    visit_with_auth regular_event_path(regular_event), 'kimura'
    visit_with_auth regular_event_path(regular_event), 'machida'
    visit_with_auth regular_event_path(regular_event), 'osnashi'
    visit_with_auth regular_event_path(regular_event), 'marumarushain2'
    visit_with_auth regular_event_path(regular_event), 'kananasi'
    visit_with_auth regular_event_path(regular_event), 'nippounashi'
    visit_with_auth regular_event_path(regular_event), 'hatsuno'
    visit_with_auth regular_event_path(regular_event), 'jobseeker'
    visit_with_auth regular_event_path(regular_event), 'advijirou'
    visit_with_auth regular_event_path(regular_event), 'hajime'
    visit_with_auth regular_event_path(regular_event), 'muryou'
    assert page.has_css?('.page-content-prev-next__item-link')
  end

  test 'has no link if there are less than ten footprints' do
    regular_event = users(:komagata).regular_events.first
    visit_with_auth regular_event_path(regular_event), 'kimura'
    visit_with_auth regular_event_path(regular_event), 'machida'
    visit_with_auth regular_event_path(regular_event), 'osnashi'
    visit_with_auth regular_event_path(regular_event), 'marumarushain2'
    visit_with_auth regular_event_path(regular_event), 'kananasi'
    visit_with_auth regular_event_path(regular_event), 'nippounashi'
    visit_with_auth regular_event_path(regular_event), 'hatsuno'
    visit_with_auth regular_event_path(regular_event), 'jobseeker'
    visit_with_auth regular_event_path(regular_event), 'advijirou'
    visit_with_auth regular_event_path(regular_event), 'hajime'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end
end

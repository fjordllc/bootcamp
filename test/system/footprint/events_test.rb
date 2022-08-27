# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::EventsTest < ApplicationSystemTestCase
  test 'should be create footprint in /events/:id' do
    event = users(:komagata).events.first
    visit_with_auth event_path(event), 'sotugyou'
    assert_text '見たよ'
    assert page.has_css?('.a-user-icon.is-sotugyou')
  end

  test 'should not footpoint with my own regular event' do
    event = users(:sotugyou).events.first
    visit_with_auth event_path(event), 'sotugyou'
    assert_no_text '見たよ'
    assert_not page.has_css?('.a-user-icon.is-sotugyou')
  end

  test 'show link if there are more than ten footprints' do
    event = users(:komagata).events.first
    visit_with_auth event_path(event), 'kimura'
    visit_with_auth event_path(event), 'machida'
    visit_with_auth event_path(event), 'osnashi'
    visit_with_auth event_path(event), 'marumarushain2'
    visit_with_auth event_path(event), 'kananasi'
    visit_with_auth event_path(event), 'nippounashi'
    visit_with_auth event_path(event), 'hatsuno'
    visit_with_auth event_path(event), 'jobseeker'
    visit_with_auth event_path(event), 'advijirou'
    visit_with_auth event_path(event), 'hajime'
    visit_with_auth event_path(event), 'muryou'
    visit_with_auth event_path(event), 'sotugyou'
    visit_with_auth event_path(event), 'adminonly'
    visit_with_auth event_path(event), 'sotugyou-with-job'
    visit_with_auth event_path(event), 'kensyu'
    assert_text '見たよ'
    assert page.has_css?('.page-content-prev-next__item-link')
  end

  test 'has no link if there are less than ten footprints' do
    event = users(:komagata).events.first
    visit_with_auth event_path(event), 'kimura'
    visit_with_auth event_path(event), 'machida'
    visit_with_auth event_path(event), 'osnashi'
    visit_with_auth event_path(event), 'marumarushain2'
    visit_with_auth event_path(event), 'kananasi'
    visit_with_auth event_path(event), 'nippounashi'
    visit_with_auth event_path(event), 'hatsuno'
    visit_with_auth event_path(event), 'jobseeker'
    visit_with_auth event_path(event), 'advijirou'
    visit_with_auth event_path(event), 'hajime'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end
end

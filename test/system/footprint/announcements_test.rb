# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::AnnouncementsTest < ApplicationSystemTestCase
  test 'should be create footprint in /announcements/:id' do
    announce = users(:komagata).announcements.first
    visit_with_auth announcement_path(announce), 'kimura'
    assert_text '見たよ'
    assert page.has_css?('.a-user-icon.is-kimura')
  end

  test 'should not footpoint with my own announcement' do
    announce = users(:komagata).announcements.first
    visit_with_auth announcement_path(announce), 'komagata'
    assert_no_text '見たよ'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end

  test 'show link if there are more than ten footprints' do
    announce = users(:komagata).announcements.first
    visit_with_auth announcement_path(announce), 'kimura'
    visit_with_auth announcement_path(announce), 'machida'
    visit_with_auth announcement_path(announce), 'osnashi'
    visit_with_auth announcement_path(announce), 'marumarushain2'
    visit_with_auth announcement_path(announce), 'kananasi'
    visit_with_auth announcement_path(announce), 'nippounashi'
    visit_with_auth announcement_path(announce), 'hatsuno'
    visit_with_auth announcement_path(announce), 'jobseeker'
    visit_with_auth announcement_path(announce), 'advijirou'
    visit_with_auth announcement_path(announce), 'hajime'
    visit_with_auth announcement_path(announce), 'muryou'
    assert page.has_css?('.page-content-prev-next__item-link')
  end

  test 'has no link if there are less than ten footprints' do
    announce = users(:komagata).announcements.first
    visit_with_auth announcement_path(announce), 'kimura'
    visit_with_auth announcement_path(announce), 'machida'
    visit_with_auth announcement_path(announce), 'osnashi'
    visit_with_auth announcement_path(announce), 'marumarushain2'
    visit_with_auth announcement_path(announce), 'kananasi'
    visit_with_auth announcement_path(announce), 'nippounashi'
    visit_with_auth announcement_path(announce), 'hatsuno'
    visit_with_auth announcement_path(announce), 'jobseeker'
    visit_with_auth announcement_path(announce), 'advijirou'
    visit_with_auth announcement_path(announce), 'hajime'
    visit_with_auth announcement_path(announce), 'muryou'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end
end

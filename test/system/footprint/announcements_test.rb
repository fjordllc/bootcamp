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
end

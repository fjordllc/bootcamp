# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::RegularEventTest < ApplicationSystemTestCase
  setup do
    @regular_event = regular_events(:regular_event1)
  end

  test 'shows regular event link on list when clicking bookmark button' do
    visit_with_auth regular_event_path(@regular_event), 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'
    click_button 'Bookmark'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit current_user_bookmarks_path
    assert_selector 'a.card-list-item-title__link', text: @regular_event.title
    click_link @regular_event.title

    assert_current_path regular_event_path(@regular_event)
  end

  test 'updates bookmarks list when toggling bookmark' do
    visit_with_auth regular_event_path(@regular_event), 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'
    click_button 'Bookmark'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit current_user_bookmarks_path
    assert_selector 'a.card-list-item-title__link', text: @regular_event.title

    visit regular_event_path(@regular_event)
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'
    click_button 'Bookmark中'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'

    visit current_user_bookmarks_path
    assert_no_selector 'a.card-list-item-title__link', text: @regular_event.title
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::EventTest < ApplicationSystemTestCase
  setup do
    @event = events(:event1)
  end

  test 'shows event link on list when clicking bookmark button' do
    visit_with_auth event_path(@event), 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'
    click_button 'Bookmark'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit current_user_bookmarks_path
    assert_selector 'a.card-list-item-title__link', text: @event.title
    click_link @event.title

    assert_current_path event_path(@event)
  end

  test 'updates bookmarks list when toggling bookmark' do
    visit_with_auth event_path(@event), 'machida'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'
    click_button 'Bookmark'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'

    visit current_user_bookmarks_path
    assert_selector 'a.card-list-item-title__link', text: @event.title

    visit event_path(@event)
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark中'
    click_button 'Bookmark中'
    wait_for_javascript_components
    assert_selector '#bookmark-button', text: 'Bookmark'

    visit current_user_bookmarks_path
    assert_no_selector 'a.card-list-item-title__link', text: @event.title
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class BookmarksTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
    @not_featured_report = reports(:report30)
  end

  test 'show featured entries lists' do
    visit_with_auth '/featured_entries', 'komagata'
    assert_text '注目エントリー'
    assert_text @report.title
  end

  test 'can feature report when the mentor or admin logged in' do
    visit_with_auth "/reports/#{@not_featured_report.id}", 'komagata'
    assert_selector '#featured-entry-button.is-inactive'
    find('#featured-entry-button').click
    # wait_for_vuejs
    assert_selector '#featured-entry-button.is-active'
  end

  test 'cannot display featured entry button without mentor or admin' do
    visit_with_auth "/reports/#{@report.id}", 'kimura'
    # wait_for_vuejs
    assert_no_selector '#featured-entry-button'

    visit_with_auth "/reports/#{@report.id}", 'komagata'
    assert_selector '#featured-entry-button'
  end

  test 'display featured report' do
    visit_with_auth '/featured_entries', 'komagata'
    assert_no_text @not_featured_report.title

    visit_with_auth "/reports/#{@not_featured_report.id}", 'komagata'
    find('#featured-entry-button').click

    visit '/featured_entries'
    assert_text @not_featured_report.title
  end

  test 'cannot display unfeatured report' do
    visit_with_auth '/featured_entries', 'komagata'
    assert_text @report.title

    visit "/reports/#{@report.id}"
    find('#featured-entry-button').click

    visit '/featured_entries'
    assert_no_text @report.title
  end
end

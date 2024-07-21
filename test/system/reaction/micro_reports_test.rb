# frozen_string_literal: true

require 'application_system_test_case'

class Reaction::MicroReportsTest < ApplicationSystemTestCase
  test 'show reaction of micro report' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'

    assert_text "👍1\n❤️1"
  end

  test 'reaction to micro report' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='eyes']").click

    assert_text "👍1\n❤️1\n👀1"
  end

  test 'delete reaction of micro report on dropdown' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='heart']").click

    assert_text '👍1'
    assert_no_text '❤️0'
  end

  test 'delete reaction of micro report on fotter' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    first(".js-reaction li[data-reaction-kind='heart']").click

    assert_text '👍1'
    assert_no_text '❤️0'
  end
end

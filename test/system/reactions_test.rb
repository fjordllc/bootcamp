# frozen_string_literal: true

require "application_system_test_case"

class ReactionsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "post new reaction for report" do
    visit report_path(reports(:report_1))
    first(".thread-body .js-reaction-dropdown-toggle").click
    first(".thread-body .js-reaction-dropdown li[data-reaction-kind='smile']").click
    assert_text "😄2"
  end

  test "destroy reaction for report from dropdown" do
    visit report_path(reports(:report_1))
    first(".thread-body .js-reaction-dropdown-toggle").click
    first(".thread-body .js-reaction-dropdown li[data-reaction-kind='thumbsup']").click
    refute_text "👍1"
  end

  test "destroy reaction for report from footer" do
    visit report_path(reports(:report_1))
    first(".thread-body .js-reaction li.is-reacted").click
    refute_text "👍1"
  end

  test "post new reaction for comment" do
    visit report_path(reports(:report_3))
    first(".thread-comment .js-reaction-dropdown-toggle").click
    first(".thread-comment .js-reaction-dropdown li[data-reaction-kind='smile']").click
    assert_text "😄1"
  end

  test "destroy reaction for comment from dropdown" do
    visit report_path(reports(:report_3))
    first(".thread-comment .js-reaction-dropdown-toggle").click
    first(".thread-comment .js-reaction-dropdown li[data-reaction-kind='heart']").click
    assert_text "❤️1"
  end

  test "destroy reaction for comment from footer" do
    visit report_path(reports(:report_3))
    first(".thread-comment .js-reaction li[data-reaction-kind='heart']").click
    assert_text "❤️1"
  end
end

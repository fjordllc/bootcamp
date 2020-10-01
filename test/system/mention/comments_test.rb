# frozen_string_literal: true

require "application_system_test_case"

module Mention
  class CommentsTest < ApplicationSystemTestCase
    setup do
      login_user "kimura", "testtest"
    end

    test "mention from a comment" do
      visit "/reports/#{reports(:report_1).id}"
      within(".thread-comment-form__form") do
        fill_in("new_comment[description]", with: "@hatsuno test")
      end
      click_button "コメントする"
      wait_for_vuejs

      login_user "hatsuno", "testtest"
      visit "/notifications"
      assert_text "kimuraさんからメンションがきました。"
    end
  end
end

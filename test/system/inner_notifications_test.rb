# frozen_string_literal: true

require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  test "do not send mail if user deny mail" do
    login_user "kimura", "testtest"
    visit "/reports/#{reports(:report_8).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal "[Bootcamp] kimuraさんからコメントが届きました。", last_mail.subject
    end
  end
end

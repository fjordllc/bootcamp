# frozen_string_literal: true

require "test_helper"

class CheckUrlMailerTest < ActionMailer::TestCase
  test "notify_error_url" do
    page_error_url = [{ id: 883692644, url: "http://localhost:3000/pages/5555555" }]
    practice_error_url = [{ id: 207936418, url: "http://homepage2.nifty.com/kamurai/CPU.htm" }, { id: 207936418, url: "http://homepage2.nifty.com/kamurai/MEMORY.htm" }, { id: 207936418, url: "http://homepage2.nifty.com/kamurai/HDD.htm" }]

    mail = CheckUrlMailer.notify_error_url(page_error_url, practice_error_url).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "[BootCamp Admin] リンク切れ報告", mail.subject
    assert_equal ["info@fjord.jp"], mail.to
    assert_equal ["info@fjord.jp"], mail.from
    assert_match %r{リンク切れがありました。}, mail.body.to_s
  end
end

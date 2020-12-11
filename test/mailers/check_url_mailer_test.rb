# frozen_string_literal: true

require 'test_helper'

class CheckUrlMailerTest < ActionMailer::TestCase
  test 'notify_error_url' do
    page_error_url = [{ id: 883_692_644, url: 'http://localhost:3000/pages/5555555' }]
    practice_error_url = [
      { id: 207_936_418, url: 'http://homepage2.nifty.com/kamurai/CPU.htm' },
      { id: 207_936_418, url: 'http://homepage2.nifty.com/kamurai/MEMORY.htm' },
      { id: 207_936_418, url: 'http://homepage2.nifty.com/kamurai/HDD.htm' }
    ]

    mail = CheckUrlMailer.notify_error_url(page_error_url, practice_error_url).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal '[BootCamp Admin] リンク切れ報告', mail.subject
    assert_equal ['info@fjord.jp'], mail.to
    assert_equal ['noreply@bootcamp.fjord.jp'], mail.from
    assert_match(/リンク切れがありました。/, mail.body.to_s)
  end
end

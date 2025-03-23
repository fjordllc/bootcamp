# frozen_string_literal: true

require 'test_helper'

class GrantCourseApplicationMailerTest < ActionMailer::TestCase
  test 'incoming' do
    grant_course_application = grant_course_applications(:grant_course_application1)
    email = GrantCourseApplicationMailer.incoming(grant_course_application).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['info@lokka.jp'], email.to
    assert_equal grant_course_application.email, email.reply_to[0]
    assert_equal '[FBC] 給付金対応コース申し込み', email.subject
    assert_match grant_course_application.full_name, email.body.to_s
    assert_match grant_course_application.email, email.body.to_s
    assert_match grant_course_application.address, email.body.to_s
    assert_match grant_course_application.tel, email.body.to_s
  end
end

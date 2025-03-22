# frozen_string_literal: true

class GrantCourseApplicationMailer < ApplicationMailer
  def incoming(grant_course_application)
    @grant_course_application = grant_course_application
    mail to: 'info@lokka.jp', reply_to: @grant_course_application.email, subject: '[FBC] 給付金対応コース申し込み'
  end
end

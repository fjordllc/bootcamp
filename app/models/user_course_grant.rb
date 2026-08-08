# frozen_string_literal: true

class UserCourseGrant
  def initialize(user)
    @user = user
  end

  def grant_course?
    course = Course.find_by(id: @user.course_id)
    @user.course_id.present? && course&.grant?
  end
end

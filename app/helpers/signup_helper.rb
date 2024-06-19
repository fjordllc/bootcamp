# frozen_string_literal: true

module SignupHelper
  def find_course(course_id)
    Course.find(course_id)
  rescue ActiveRecord::RecordNotFound
    Course.find_default_course
  end
end

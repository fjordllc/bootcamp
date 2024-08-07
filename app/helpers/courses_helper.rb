# frozen_string_literal: true

module CoursesHelper
  def find_course(course_id)
    Course.find_by(id: course_id) || Course.default_course
  end
end

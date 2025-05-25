# frozen_string_literal: true

module CoursesHelper
  def find_course(course_id)
    Course.find_by(id: course_id) || Course.default_course
  end

  def new_grant_course_user_url
    course = Course.find_by(title: 'Railsエンジニア（Reスキル講座認定）')
    new_user_url(params: { course_id: course.id })
  end
end

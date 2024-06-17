# frozen_string_literal: true

module SignupHelper
  def find_course(course_id)
    Course.find(course_id)
  rescue ActiveRecord::RecordNotFound
    find_default_course
  end

  def find_default_course
    Course.find_by(title: 'Railsプログラマー')
  end
end

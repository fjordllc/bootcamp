# frozen_string_literal: true

class API::Courses::PracticesController < API::BaseController
  before_action :require_login_for_api

  def index
    @course_id = params[:course_id]
    @categories = Category
                  .joins(:courses_categories)
                  .where(courses_categories: { course_id: @course_id })
                  .includes(practices: [{ started_or_submitted_students: { avatar_attachment: :blob } }, :learning_minute_statistic, :practices_books])
                  .order('courses_categories.position')
    @learnings = current_user.learnings
    @completed_practices_size_by_category = @current_user_practice.completed_practices_size_by_category
  end
end

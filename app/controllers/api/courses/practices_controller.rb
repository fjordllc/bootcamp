# frozen_string_literal: true

class API::Courses::PracticesController < API::BaseController
  before_action :require_login_for_api

  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories
                         .includes(practices: [{ started_students: { avatar_attachment: :blob } }, :learning_minute_statistic])
                         .order(:position)
    @learnings = current_user.learnings
    @completed_practices_size_by_category = current_user.completed_practices_size_by_category
  end
end

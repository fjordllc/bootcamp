# frozen_string_literal: true

class API::Courses::PracticesController < API::BaseController
  before_action :require_login

  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories
                         .includes(practices: [{ started_students: { avatar_attachment: :blob } }, :learning_minute_statistic])
                         .order(:position)
    @learnings = current_user.learnings
  end
end

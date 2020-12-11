# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  before_action :require_login

  def index
    @course = Course.find(params[:course_id])
    @categories = @course.categories
                         .includes(practices: [{ started_students: { avatar_attachment: :blob } }, :learning_minute_statistic])
                         .order(:position)
    @learnings = current_user.learnings

    # TODO: リタイアした人のセッションが切れたら外す
    return unless current_user.retired_on?

    logout
    redirect_to retire_path
  end
end

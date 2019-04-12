# frozen_string_literal: true

class Courses::PracticesController < MemberAreaController
  def index
    @course = Course.find(params[:course_id])

    # TODO: リタイアした人のセッションが切れたら外す
    if current_user.retired_on?
      logout
      redirect_to retire_path
    end
  end
end

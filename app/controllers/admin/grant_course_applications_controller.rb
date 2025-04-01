# frozen_string_literal: true

class Admin::GrantCourseApplicationsController < AdminController
  PAGER_NUMBER = 20

  def index
    @grant_course_applications = GrantCourseApplication.order(created_at: :desc).page(params[:page]).per(PAGER_NUMBER)
  end

  def show
    @grant_course_application = GrantCourseApplication.find(params[:id])
  end
end

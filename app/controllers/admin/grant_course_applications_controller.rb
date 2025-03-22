# frozen_string_literal: true

class Admin::GrantCourseApplicationsController < AdminController
  PAGER_NUMBER = 20

  def index
    per = params[:per] || PAGER_NUMBER
    @grant_course_applications = GrantCourseApplication.order(created_at: :desc).page(params[:page]).per(per)
  end

  def show
    @grant_course_application = GrantCourseApplication.find(params[:id])
  end
end

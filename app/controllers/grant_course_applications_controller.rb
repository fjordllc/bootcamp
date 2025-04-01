# frozen_string_literal: true

class GrantCourseApplicationsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def new
    @grant_course_application = GrantCourseApplication.new
  end

  def create
    @grant_course_application = GrantCourseApplication.new(grant_course_application_params)

    if @grant_course_application.save
      GrantCourseApplicationMailer.incoming(@grant_course_application).deliver_later
      redirect_to created_grant_course_applications_url
    else
      render :new
    end
  end

  def created; end

  private

  def grant_course_application_params
    params.require(:grant_course_application).permit(
      :last_name, :first_name, :email,
      :zip1, :zip2, :prefecture_code, :address1, :address2,
      :tel1, :tel2, :tel3, :trial_period, :privacy_policy
    )
  end
end

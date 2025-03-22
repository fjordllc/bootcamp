# frozen_string_literal: true

class GrantCourseApplicationsController < ApplicationController
  include Recaptchable::V3
  skip_before_action :require_active_user_login, raise: false

  def new
    @grant_course_application = GrantCourseApplication.new
  end

  def create
    @grant_course_application = GrantCourseApplication.new(grant_course_application_params)
    result = valid_recaptcha?('grant_course_application')

    if result && @grant_course_application.save
      GrantCourseApplicationMailer.incoming(@grant_course_application).deliver_later
      redirect_to created_grant_course_applications_url
    else
      flash.now[:alert] = 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。' unless result
      render :new
    end
  end

  def created; end

  private

  def grant_course_application_params
    params.require(:grant_course_application).permit(:name, :email, :address, :phone, :trial_period, :privacy_policy)
  end
end

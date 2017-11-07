class LearningsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_practice, only: %i(update)
  layout false

  def update
    learning = Learning.find_or_create_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )
    if params[:status].nil?
      learning.status = :complete
    else
      learning.status = params[:status].to_sym
    end

    text = "<#{user_url(current_user)}|#{current_user.login_name}>が<#{practice_url(@practice)}|#{@practice.title}>を#{t learning.status}しました。"
    notify text,
      username: "#{current_user.login_name}@256interns.com",
      icon_url: gravatar_url(current_user)

    if learning.save
      respond_to do |format|
        format.js { head :ok }
        format.html { redirect_to practices_path, notice: "「#{@practice.title}」" + t("notice_completed_practice") }
      end
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end

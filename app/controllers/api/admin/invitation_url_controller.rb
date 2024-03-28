# frozen_string_literal: true

class API::Admin::InvitationUrlController < API::Admin::BaseController
  def index
    url = new_user_url(
      company_id: params[:company_id],
      role: params[:role],
      course_id: params[:course_id],
      token: ENV['TOKEN'] || 'token'
    )
    render json: { url: }
  end
end

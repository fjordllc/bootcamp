# frozen_string_literal: true

class API::Practices::LearningController < API::BaseController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper

  def update
    learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    if params[:status].nil?
      learning.status = :complete
    else
      learning.status = params[:status].to_sym
    end

    status = learning.new_record? ? :created : :ok

    if learning.save
      head status
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private
    def notify_learning
      subject = "<#{user_url(current_user)}|#{current_user.login_name}>"
      object = "<#{practice_url(@practice)}|#{@practice.title}>"
      verb = "#{t learning.status}しました。"
      text = "#{subject}が#{object}を#{verb}"
      notify text,
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: gravatar_url(current_user, secure: true)
    end
end

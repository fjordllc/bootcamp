# frozen_string_literal: true

class API::Practices::LearningController < API::BaseController
  include Rails.application.routes.url_helpers

  def show
    @learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    if @learning.new_record?
      @learning.status = :unstarted
    end
  end

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
      notify_learning(user: current_user, learning: learning)
      head status
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private
    def notify_learning(user:, learning:)
      subject = "<#{user_url(user)}|#{user.login_name}>"
      object = "<#{practice_url(learning.practice)}|#{learning.practice.title}>"
      verb = "#{t("activerecord.enums.learning.status." + learning.status.to_s)}しました。"
      text = "#{subject}が#{object}を#{verb}"
      SlackNotification.notify text,
                               username: "#{current_user.login_name}@bootcamp.fjord.jp",
                               icon_url: current_user.avatar_url
    end
end

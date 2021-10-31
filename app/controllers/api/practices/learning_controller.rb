# frozen_string_literal: true

class API::Practices::LearningController < API::BaseController
  include Rails.application.routes.url_helpers

  def show
    @learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    return unless @learning.new_record?

    @learning.status = :unstarted
  end

  def update
    learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    learning.status = if params[:status].nil?
                        :complete
                      else
                        params[:status].to_sym
                      end

    status = learning.new_record? ? :created : :ok

    if learning.save
      notify_to_chat_for_employment_counseling(learning) if status == :created && learning.practice_id == 163
      head status
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private

  def notify_to_chat_for_employment_counseling(learning)
    ChatNotifier.message(
      "お知らせ：#{learning.user.name}がプラクティス「#{learning.practice.title}」に進みました。",
      webhook_url: ENV['DISCORD_EMPLOYMENT_COUNSELING_WEBHOOK_URL']
    )
  end
end

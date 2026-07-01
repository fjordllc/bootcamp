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
    return render_invalid_status if requested_status.blank?

    learning = find_or_initialize_learning

    return render_incomplete_practice_quiz if learning.complete? && !practice.completable_by?(current_user)

    save_learning(learning)
  end

  private

  def save_learning(learning)
    status = learning.new_record? ? :created : :ok

    if learning.save
      ActiveSupport::Notifications.instrument('learning.create', user: learning.user)
      notify_to_chat_for_employment_counseling(learning) if status == :created && learning.practice.title == '就職相談部屋を作る'
      head status
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  def render_invalid_status
    render json: { error: 'status is invalid' }, status: :unprocessable_entity
  end

  def render_incomplete_practice_quiz
    render json: { error: '理解度テストに合格すると、このプラクティスを修了できます。' }, status: :unprocessable_entity
  end

  def practice
    @practice ||= Practice.find(params[:practice_id])
  end

  def find_or_initialize_learning
    Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: practice.id
    ).tap do |learning|
      learning.status = requested_status
    end
  end

  def requested_status
    return :complete if params[:status].nil?
    return params[:status].to_sym if Learning.statuses.key?(params[:status])

    nil
  end

  def notify_to_chat_for_employment_counseling(learning)
    ChatNotifier.message(
      "お知らせ：#{learning.user.name}がプラクティス「#{learning.practice.title}」に進みました。",
      webhook_url: ENV['DISCORD_ADMIN_WEBHOOK_URL']
    )
  end
end

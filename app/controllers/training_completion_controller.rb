# frozen_string_literal: true

class TrainingCompletionController < ApplicationController
  before_action :require_trainee_login, only: %i[new create]
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(training_complete_params)
    current_user.training_completed_at = Time.current
    if current_user.save(context: :training_completion)
      user = current_user
      current_user.cancel_participation_from_not_finished_regular_events
      current_user.hand_over_not_finished_regular_event_organizers
      ActiveSupport::Notifications.instrument('training_completion.create', user:)
      user.clear_github_data
      notify_to_user(user)
      notify_to_admins(user)
      notify_to_mentors(user)

      logout
      redirect_to training_completion_url
    else
      current_user.training_completed_at = nil
      render :new
    end
  end

  private

  def training_complete_params
    params.require(:user).permit(:satisfaction, :opinion)
  end

  def notify_to_user(user)
    UserMailer.training_complete(user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_to_admins(user)
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: user, receiver: admin_user).notify(:training_completed)
    end
  end

  def notify_to_mentors(user)
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: user, receiver: mentor_user).notify(:training_completed)
    end
  end
end

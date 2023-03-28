# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save(context: :retirement)
      user = current_user
      Newspaper.publish(:retirement_create, user)
      begin
        UserMailer.retire(user).deliver_now
      rescue Postmark::InactiveRecipientError => e
        logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
      end

      destroy_subscription
      notify_to_admins
      notify_to_mentors
      logout
      redirect_to retirement_url
    else
      current_user.retired_on = nil
      render :new
    end
  end

  private

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end

  def destroy_subscription
    Subscription.new.destroy(current_user.subscription_id) if current_user.subscription_id
  end

  def notify_to_admins
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: current_user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_mentors
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: current_user, receiver: mentor_user).notify(:retired)
    end
  end
end

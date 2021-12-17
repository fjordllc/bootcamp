# frozen_string_literal: true

class RetirementController < ApplicationController
  before_action :require_login, except: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save(context: :retirement)
      user = current_user
      UserMailer.retire(user).deliver_now
      destroy_subscription
      notify_to_admins
      logout
      redirect_to retirement_url
    else
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
      Notification.retired(current_user, admin_user)
      NotificationFacade.retired(current_user, admin_user)
    end
  end
end

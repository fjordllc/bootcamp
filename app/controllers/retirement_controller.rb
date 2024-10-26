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
      current_user.cancel_participation_from_regular_events
      current_user.delete_and_assign_new_organizer
      Newspaper.publish(:retirement_create, { user: })

      destroy_subscription(user)
      destroy_card(user)
      notify_to_user(user)
      notify_to_admins(user)
      notify_to_mentors(user)
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

  def destroy_subscription(user)
    Subscription.new.destroy(user.subscription_id) if user.subscription_id?
  end

  def destroy_card(user)
    Card.destroy_all(user.customer_id) if user.customer_id?
  end

  def notify_to_user(user)
    UserMailer.retire(user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_to_admins(user)
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_mentors(user)
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: user, receiver: mentor_user).notify(:retired)
    end
  end
end

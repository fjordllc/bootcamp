# frozen_string_literal: true

class HibernationController < ApplicationController
  before_action :require_login, except: %i[show]

  def show; end

  def new
    @hibernation = Hibernation.new
  end

  def create
    @hibernation = Hibernation.new(hibernation_params)
    @hibernation.user = current_user

    if @hibernation.save
      update_hibernated_at!
      destroy_subscription!
      logout
      redirect_to hibernation_path
    else
      render :new
    end
  end

  private

  def hibernation_params
    params.require(:hibernation).permit(:reason, :scheduled_return_on, :returned_on)
  end

  def update_hibernated_at!
    current_user.hibernated_at = @hibernation.created_at
    current_user.save!(validate: false)
  end

  def destroy_subscription!
    return nil unless Rails.env.production?

    Subscription.new.destroy(current_user.subscription_id) if current_user.subscription_id
  end

  def notify_to_mentors_and_admins
    User.admins_and_mentors.each do |admin_or_mentor|
      NotificationFacade.retired(current_user, admin_or_mentor)
    end
  end
end

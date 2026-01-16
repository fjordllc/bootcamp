# frozen_string_literal: true

class HibernationController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

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
      notify_to_chat
      notify_to_mentors_and_admins
      captured_regular_events_and_organizers = current_user.capture_before_regular_event_organizers
      current_user.cancel_participation_from_regular_events
      current_user.delete_and_assign_new_organizer
      notify_to_new_regular_event_organizer(captured_regular_events_and_organizers)
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
    return nil if !Rails.env.production? || staging?

    Subscription.new.destroy(current_user.subscription_id) if current_user.subscription_id
  end

  def notify_to_mentors_and_admins
    User.admins_and_mentors.each do |admin_or_mentor|
      ActivityDelivery.with(sender: current_user, receiver: admin_or_mentor).notify(:hibernated)
    end
  end

  def notify_to_chat
    DiscordNotifier.with(sender: current_user).hibernated.notify_now
  end

  def notify_to_new_regular_event_organizer(regular_events_and_organizers)
    regular_events_and_organizers.each do |regular_event_and_organizer|
      ActiveSupport::Notifications.instrument('organizer.create',
                                              regular_event: regular_event_and_organizer[:regular_event],
                                              before_organizer_ids: regular_event_and_organizer[:before_organizer_ids],
                                              sender: current_user)
    end
  end
end

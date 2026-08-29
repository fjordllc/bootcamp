# frozen_string_literal: true

class Hibernation < ApplicationRecord
  include StagingEnvironment

  belongs_to :user
  validates :reason, presence: true
  validates :scheduled_return_on, presence: true

  def execute
    update_hibernated_at!
    destroy_subscription!
    notify_to_chat
    notify_to_mentors_and_admins
    user.clean_up_regular_events
  end

  def self.hibernate_by_admin(user:, scheduled_return_on:)
    hibernation = new(
      user:,
      reason: '管理者操作',
      scheduled_return_on:
    )
    if hibernation.save
      hibernation.execute
    else
      render :edit
      false
    end
  end

  private

  def update_hibernated_at!
    user.hibernated_at = created_at
    user.save!(validate: false)
  end

  def destroy_subscription!
    return nil if !Rails.env.production? || staging?

    Subscription.new.destroy(user.subscription_id) if user.subscription_id?
  end

  def notify_to_mentors_and_admins
    User.admins_and_mentors.each do |admin_or_mentor|
      ActivityDelivery.with(sender: user, receiver: admin_or_mentor).notify(:hibernated)
    end
  end

  def notify_to_chat
    DiscordNotifier.with(sender: user).hibernated.notify_now
  end
end

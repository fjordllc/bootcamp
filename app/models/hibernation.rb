# frozen_string_literal: true

class Hibernation < ApplicationRecord
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

  private

  def update_hibernated_at!
    user.hibernated_at = created_at
    user.save!(validate: false)
  end

  def staging?
    ENV['DB_NAME'] == 'bootcamp_staging'
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

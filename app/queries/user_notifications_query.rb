# frozen_string_literal: true

class UserNotificationsQuery < Patterns::Query
  queries Notification

  private

  def initialize(relation = Notification.all, user:, target:, status:)
    super(relation)
    @user = user
    @target = target
    @status = status
  end

  def query
    latest_notifications = @user.notifications
                                .by_target(validated_target)
                                .by_read_status(@status)
                                .latest_of_each_link

    Notification.with_avatar
                .from(latest_notifications, :notifications)
                .order(created_at: :desc)
  end

  def validated_target
    Notification::TARGETS_TO_KINDS.key?(@target) ? @target : nil
  end
end

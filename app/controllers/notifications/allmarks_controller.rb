# frozen_string_literal: true

class Notifications::AllmarksController < ApplicationController
  def create
    @notifications = current_user.notifications
    @notifications.update_all(read: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    Cache.delete_mentioned_and_unread_notification_count(current_user.id) # 全ての通知件数分のコールバックが実行されるとサーバーに負荷をかけすぎることもありそうなため、コールバックを使わずにキャッシュを削除する
    redirect_to notifications_path, notice: '全て既読にしました'
  end
end

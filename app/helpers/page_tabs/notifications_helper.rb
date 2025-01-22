# frozen_string_literal: true

module PageTabs
  module NotificationsHelper
    def notifications_page_tabs
      target = params[:target] || 'all'
      active_tab = t("notification.#{target}")
      tabs = []
      tabs << { name: '全て', link: notifications_path(status: 'unread'), badge: notification_count(:all) }
      tabs << { name: 'お知らせ', link: notifications_path(target: 'announcement', status: 'unread'), badge: notification_count(:announcement) }
      tabs << { name: 'メンション', link: notifications_path(target: 'mention', status: 'unread'), badge: notification_count(:mention) }
      tabs << { name: 'コメント', link: notifications_path(target: 'comment', status: 'unread'), badge: notification_count(:comment) }
      tabs << { name: '提出物の確認', link: notifications_path(target: 'check', status: 'unread'), badge: notification_count(:check) }
      tabs << { name: 'Watch中', link: notifications_path(target: 'watching', status: 'unread'), badge: notification_count(:watching) }
      tabs << { name: 'フォロー中', link: notifications_path(target: 'following_report', status: 'unread'), badge: notification_count(:following_report) }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end

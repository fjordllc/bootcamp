import React from 'react'
import { useNotification } from './NotificationsBell'

export default function BellButton({ setShowNotifications }) {
  // 通知ベルボタン上に表示される数が、常に「未読の通知の数」を表すようにするために、
  // 本コンポーネントでも未読の通知データを独自に取得する
  const { notifications } = useNotification('unread')
  const isLoading = !notifications
  const unreadNotificationExist = notifications?.length > 0

  const unreadNotificationCount = () => {
    if (isLoading) return

    const count = notifications.length
    return count > 99 ? '99+' : String(count)
  }

  return (
    <div
      onClick={() => setShowNotifications(true)}
      className="header-links__link test-show-notifications">
      <div className="header-links__link test-bell">
        <div className="header-notification-icon">
          {unreadNotificationExist && (
            <div className="header-notification-count a-notification-count test-notification-count">
              {unreadNotificationCount()}
            </div>
          )}
          {isLoading && (
            <div className="header-notification-count a-notification-count is-loading"></div>
          )}
          <i className="fa-solid fa-bell"></i>
          <div className="header-links__link-label">通知</div>
        </div>
      </div>
    </div>
  )
}

import React from 'react'
import { useNotification } from './NotificationsBell'

export default function BellButton({ setShowNotifications }) {
  const { notifications } = useNotification('unread')
  const isLoading = !notifications

  const notificationExist = notifications?.length > 0

  const notificationCount = () => {
    if (isLoading) return

    const count = notifications.length
    return count > 99 ? '99+' : String(count)
  }

  const openNotifications = () => {
    if (isLoading) return

    setShowNotifications(true)
  }

  return (
    <label
      onClick={openNotifications}
      className="header-links__link test-show-notifications">
      <div className="header-links__link test-bell">
        <div className="header-notification-icon">
          {notificationExist && (
            <div className="header-notification-count a-notification-count test-notification-count">
              {notificationCount()}
            </div>
          )}
          {isLoading && (
            <div className="header-notification-count a-notification-count is-loading"></div>
          )}
          <i className="fa-solid fa-bell"></i>
          <div className="header-links__link-label">通知</div>
        </div>
      </div>
    </label>
  )
}

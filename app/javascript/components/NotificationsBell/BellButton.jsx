import React from 'react'
import useSWR from 'swr'
import fetcher from '../../fetcher'

export default function BellButton({ setShowNotifications }) {
  const url = '/api/notifications.json?status=unread'
  const { data } = useSWR(url, fetcher)

  const notificationExist = data?.notifications.length > 0

  const notificationCount = () => {
    if (!data) return

    const count = data.notifications.length
    return count > 99 ? '99+' : String(count)
  }

  const openNotifications = () => {
    if (!data) return

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
          {!data && (
            <div className="header-notification-count a-notification-count is-loading"></div>
          )}
          <i className="fa-solid fa-bell"></i>
          <div className="header-links__link-label">通知</div>
        </div>
      </div>
    </label>
  )
}

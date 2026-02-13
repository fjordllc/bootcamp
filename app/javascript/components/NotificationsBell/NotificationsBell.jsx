import React, { useState } from 'react'
import useSWR from 'swr'
import BellButton from './BellButton'
import Header from './Header'
import Notifications from './Notifications'
import Footer from './Footer'
import { get } from '@rails/request.js'
const fetcher = (url) =>
  get(url, { responseKind: 'json' }).then((res) => res.json)

export function useNotification(status) {
  const baseUrl = '/api/notifications.json'
  const page = 1
  const per = 10
  const apiKey =
    status === 'all'
      ? `${baseUrl}?page=${page}&per=${per}`
      : `${baseUrl}?status=${status}`
  const { data, error } = useSWR(apiKey, fetcher)
  return { notifications: data?.notifications, error }
}

export default function NotificationsBell() {
  const [showNotifications, setShowNotifications] = useState(false)
  const [targetStatus, setTargetStatus] = useState('unread')

  const { notifications, error } = useNotification(targetStatus)

  const notificationsCount = notifications?.length

  const clickOutsideNotifications = (e) => {
    if (e.target !== e.currentTarget) return

    setShowNotifications(false)
  }

  if (error) {
    console.warn(error)
    return <div>failed to load</div>
  }

  return (
    <>
      <BellButton setShowNotifications={setShowNotifications} />
      {showNotifications && (
        <>
          <label
            className="header-dropdown__background is-notification"
            onClick={clickOutsideNotifications}></label>
          <div className="header-dropdown__inner is-notification">
            <Header
              notificationsCount={notificationsCount}
              targetStatus={targetStatus}
              setTargetStatus={setTargetStatus}
            />
            <Notifications
              notifications={notifications}
              targetStatus={targetStatus}
            />
            {targetStatus === 'unread' && (
              <Footer notificationsCount={notificationsCount} />
            )}
          </div>
        </>
      )}
    </>
  )
}

import React, { useState } from 'react'
import useSWR from 'swr'
import BellButton from './BellButton'
import fetcher from '../../fetcher'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(relativeTime)

export default function NotificationsBell() {
  const [showNotifications, setShowNotifications] = useState(false)

  const url = '/api/notifications.json?status=unread'
  const { data, error } = useSWR(url, fetcher)

  const notificationExist = data?.notifications.length > 0
  const hasCountClass = notificationExist ? 'has-count' : 'has-no-count'

  const clickOutsideNotifications = (e) => {
    if (e.target !== e.currentTarget) return

    setShowNotifications(false)
  }

  const openUnconfirmedItems = () => {
    const links = document.querySelectorAll(
      '.header-dropdown__item-link.unconfirmed_link'
    )
    links.forEach((link) => {
      window.open(link.href, '_target', 'noopener')
    })
  }

  if (error) {
    console.warn(error)
    return <div>failed to load</div>
  }

  return (
    <div className={hasCountClass}>
      <BellButton setShowNotifications={setShowNotifications} />
      {data && showNotifications && (
        <div>
          <label
            className="header-dropdown__background"
            onClick={clickOutsideNotifications}></label>
          <div className="header-dropdown__inner is-notification">
            <ul className="header-dropdown__items">
              {data.notifications.map((notification) => {
                return (
                  <Notification
                    key={notification.id}
                    notification={notification}
                  />
                )
              })}
            </ul>
            <footer className="header-dropdown__footer">
              <a
                href="/notifications?status=unread"
                className="header-dropdown__footer-link">
                全ての未読通知
              </a>
              <a href="/notifications" className="header-dropdown__footer-link">
                全ての通知
              </a>
              <a
                href="/notifications/allmarks"
                className="header-dropdown__footer-link"
                data-method="post">
                全て既読にする
              </a>
              <button
                className="header-dropdown__footer-link"
                onClick={openUnconfirmedItems}>
                全て別タブで開く
              </button>
            </footer>
          </div>
        </div>
      )}
    </div>
  )
}

function Notification({ notification }) {
  const createdAtFromNow = (createdAt) => {
    return dayjs(createdAt).fromNow()
  }

  return (
    <li className="header-dropdown__item">
      <a
        href={notification.path}
        className="header-dropdown__item-link unconfirmed_link">
        <div className="header-notifications-item__body">
          <span
            className={`a-user-role header-notifications-item__user-icon is-${notification.sender.primary_role}`}>
            <img
              src={notification.sender.avatar_url}
              className="a-user-icon"
              alt="User Icon"
            />
          </span>
          <div className="header-notifications-item__message">
            <p className="test-notification-message">{notification.message}</p>
          </div>
          <time className="header-notifications-item__created-at">
            {createdAtFromNow(notification.created_at)}
          </time>
        </div>
      </a>
    </li>
  )
}

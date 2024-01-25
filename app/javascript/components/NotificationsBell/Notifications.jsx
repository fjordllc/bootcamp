import React from 'react'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(relativeTime)

export default function Notifications({ data }) {
  return (
    <ul className="header-dropdown__items">
      {data.notifications.map((notification) => {
        return (
          <Notification key={notification.id} notification={notification} />
        )
      })}
    </ul>
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

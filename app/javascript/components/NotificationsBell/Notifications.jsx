import React from 'react'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(relativeTime)

export default function Notifications({ notifications, targetStatus }) {
  const isLoading = !notifications
  const isUnreadTab = targetStatus === 'unread'

  if (isLoading) {
    return (
      <div className="page-content loading">
        <LoadingListPlaceholder />
      </div>
    )
  } else if (notifications.length === 0) {
    return (
      <div className="a-empty-message mb-8">
        <div className="a-empty-message__icon">
          <i className="fa-regular fa-smile" />
        </div>
        <p className="a-empty-message__text">
          {isUnreadTab ? '未読の通知はありません' : '通知はありません'}
        </p>
        <div className="header-dropdown__page-link-container mt-8">
          {isUnreadTab && (
            <a href="/notifications" className="header-dropdown__page-link">
              通知一覧へ
            </a>
          )}
        </div>
      </div>
    )
  } else {
    return (
      <ul className="header-dropdown__items">
        {notifications.map((notification) => {
          return (
            <Notification key={notification.id} notification={notification} />
          )
        })}
      </ul>
    )
  }
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

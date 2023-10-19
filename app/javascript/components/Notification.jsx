import React, { useEffect, useState } from 'react'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default function Notification({ notification }) {
  const formatCreatedAtInJapanese = () => {
    return dayjs(notification.created_at).format('YYYY年MM月DD日(ddd) HH:mm')
  }
  const formatRoleClass = () => {
    return `is-${notification.sender.primary_role}`
  }

  const [formattedCreatedAt, setFormattedCreatedAt] = useState(
    formatCreatedAtInJapanese
  )
  const [formattedroleClass, setFormattedRoleClass] = useState(formatRoleClass)

  useEffect(() => {
    setFormattedCreatedAt(formatCreatedAtInJapanese)
    setFormattedRoleClass(formatRoleClass)
  }, [notification.created_at, notification.sender.primary_role])

  return (
    <div
      className={`card-list-item ${
        notification.read ? 'is-read' : 'is-unread'
      }`}>
      <div className="card-list-item__inner">
        <div className="card-list-item__user">
          <img
            className={`card-list-item__user-icon a-user-icon ${formattedroleClass}`}
            title={notification.sender.icon_title}
            src={notification.sender.avatar_url}
          />
        </div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              <div className="card-list-item-title__start">
                {notification.read === false && (
                  <div className="a-list-item-badge is-unread">
                    <span>未読</span>
                  </div>
                )}
                <h2 className="card-list-item-title__title" itemProp="name">
                  <a
                    className="card-list-item-title__link a-text-link js-unconfirmed-link"
                    href={notification.path}
                    itemProp="url">
                    <span className="card-list-item-title__link-label">
                      {notification.message}
                    </span>
                  </a>
                </h2>
              </div>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <div className="card-list-item-meta__item">
                  <time className="a-meta" dateTime={notification.created_at}>
                    {formattedCreatedAt}
                  </time>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

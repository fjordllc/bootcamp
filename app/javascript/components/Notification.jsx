import React, { useEffect, useRef } from 'react'
import userIcon from '../user-icon.js'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default function Notification({ notification }) {
  // userIconの非React化により、useRef,useEffectを導入している。
  const userIconRef = useRef(null)
  useEffect(() => {
    const linkClass = 'card-list-item__user-link'
    const imgClasses = ['card-list-item__user-icon', 'a-user-icon']

    const userIconElement = userIcon({
      user: notification.sender,
      linkClass,
      imgClasses
    })

    if (userIconRef.current) {
      userIconRef.current.innerHTML = ''
      userIconRef.current.appendChild(userIconElement)
    }
  }, [notification.sender])

  const createdAt = dayjs(notification.created_at).format(
    'YYYY年MM月DD日(ddd) HH:mm'
  )

  return (
    <div
      className={`card-list-item ${
        notification.read ? 'is-read' : 'is-unread'
      }`}>
      <div className="card-list-item__inner">
        <div className="card-list-item__user" ref={userIconRef}></div>
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
                    {createdAt}
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

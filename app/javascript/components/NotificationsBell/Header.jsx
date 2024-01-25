import React from 'react'

export default function Header({
  notificationsCount,
  targetStatus,
  setTargetStatus
}) {
  const isUnreadTab = targetStatus === 'unread'

  const notificationsUrl = isUnreadTab
    ? '/notifications?status=unread'
    : '/notifications'
  const linkLabel = isUnreadTab ? '全ての未読通知一覧へ' : '全ての通知一覧へ'

  return (
    <header>
      <nav className="pill-nav">
        <div className="container">
          <ul className="pill-nav__items">
            <li className="pill-nav__item">
              <div
                className={`pill-nav__item-link`}
                onClick={() => {
                  setTargetStatus('unread')
                }}>
                未読
              </div>
            </li>
            <li className="pill-nav__item">
              <div
                className={`pill-nav__item-link`}
                onClick={() => {
                  setTargetStatus(null)
                }}>
                全て
              </div>
            </li>
          </ul>
        </div>
      </nav>
      {notificationsCount > 0 && <a href={notificationsUrl}>{linkLabel}</a>}
    </header>
  )
}

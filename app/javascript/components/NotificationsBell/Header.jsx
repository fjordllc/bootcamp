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
    <header className='header-dropdown__header'>
      <nav className="pill-nav is-half">
        <ul className="pill-nav__items">
          <li className="pill-nav__item">
            <div
              className={`pill-nav__item-link w-full`}
              onClick={() => {
                setTargetStatus('unread')
              }}>
              未読
            </div>
          </li>
          <li className="pill-nav__item">
            <div
              className={`pill-nav__item-link w-full`}
              onClick={() => {
                setTargetStatus(null)
              }}>
              全て
            </div>
          </li>
        </ul>
      </nav>
      {notificationsCount > 0 && <div className='header-dropdown__page-link-container'><a href={notificationsUrl} className="header-dropdown__page-link">{linkLabel}</a></div>}
    </header>
  )
}

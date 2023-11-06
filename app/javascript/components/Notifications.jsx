import React from 'react'
import Notification from './Notification'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Pagination from './Pagination'
import UnconfirmedLink from './UnconfirmedLink'
import useSWR from 'swr'
import fetcher from '../fetcher'
import usePage from './hooks/usePage'

export default function Notifications({ isMentor }) {
  const per = 20
  const isUnreadPage = () => {
    const params = new URLSearchParams(location.search)
    return params.get('status') !== null && params.get('status') === 'unread'
  }
  const params = new URLSearchParams(location.search)
  const url = () => {
    const target = params.get('target') ? `&target=${params.get('target')}` : ''
    const status = params.get('status') ? `&status=${params.get('status')}` : ''
    const page = params.get('page') ? `page=${params.get('page')}` : 'page=1'
    return `/api/notifications.json?${page}${target}${status}`
  }

  const { data, error } = useSWR(url, fetcher)

  const { page, setPage } = usePage()

  if (error) {
    console.warn(error)
    return <div>failed to load</div>
  }

  if (!data) {
    return (
      <div id="notifications" className="page-content loading">
        <LoadingListPlaceholder />
      </div>
    )
  } else if (data.notifications.length === 0) {
    return (
      <div className="o-empty-message">
        <div className="o-empty-message__icon">
          <i className="fa-regular fa-smile" />
        </div>
        <p className="o-empty-message__text">
          {isUnreadPage ? '未読の通知はありません' : '通知はありません'}
        </p>
      </div>
    )
  } else {
    return (
      <>
        <nav className="pill-nav">
          <div className="container">
            <ul className="pill-nav__items">
              <li className="pill-nav__item">
                <a
                  className={`pill-nav__item-link ${
                    params.get('status') === 'unread' ? 'is-active' : ''
                  }`}
                  href={`/notifications?status=unread${
                    params.get('target')
                      ? `&target=${params.get('target')}`
                      : ''
                  }`}>
                  未読
                </a>
              </li>
              <li className="pill-nav__item">
                <a
                  className={`pill-nav__item-link ${
                    params.get('status') === 'unread' ? '' : 'is-active'
                  }`}
                  href={`/notifications${
                    params.get('target')
                      ? `?target=${params.get('target')}`
                      : ''
                  }`}>
                  全て
                </a>
              </li>
            </ul>
          </div>
        </nav>
        <div id="notifications" className="page-content loaded">
          {data.total_pages > 1 && (
            <nav className="pagination">
              <Pagination
                sum={data.total_pages * per}
                per={per}
                page={page}
                setPage={setPage}
              />
            </nav>
          )}
          <div className="card-list a-card">
            {data.notifications.map((notification) => {
              return (
                <Notification
                  key={notification.id}
                  notification={notification}
                />
              )
            })}
          </div>
          {isMentor && isUnreadPage() && (
            <UnconfirmedLink label="未読の通知を一括で開く" />
          )}
          {data.total_pages > 1 && (
            <nav className="pagination">
              <Pagination
                sum={data.total_pages * per}
                per={per}
                page={page}
                setPage={setPage}
              />
            </nav>
          )}
        </div>
      </>
    )
  }
}

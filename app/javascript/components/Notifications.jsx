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
    return params.get('status') === 'unread'
  }
  const apiUrl = () => {
    const searchParams = new URLSearchParams()
    const params = new URLSearchParams(location.search)
    const target = params.get('target')
    if (target) {
      searchParams.set('target', target)
    }

    const status = params.get('status')
    if (status) {
      searchParams.set('status', status)
    }

    const page = params.get('page') ?? 1
    searchParams.set('page', page)

    const url = new URL('api/notifications.json', location.origin)
    url.search = searchParams

    return url.toString()
  }

  const { page, setPage } = usePage()
  const { data, error } = useSWR(apiUrl, fetcher)

  if (error) {
    console.warn(error)
    return <div>failed to load</div>
  } else if (!data) {
    return (
      <div id="notifications" className="page-content loading">
        <LoadingListPlaceholder />
      </div>
    )
  } else if (data.notifications.length === 0) {
    return (
      <>
        <FilterButton />
        <div className="a-empty-message">
          <div className="a-empty-message__icon">
            <i className="fa-regular fa-smile" />
          </div>
          <p className="a-empty-message__text">
            {isUnreadPage() ? '未読の通知はありません' : '通知はありません'}
          </p>
        </div>
      </>
    )
  }

  return (
    <>
      <FilterButton />
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
              <Notification key={notification.id} notification={notification} />
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

const FilterButton = () => {
  const filterButtonUrl = (status) => {
    const searchParams = new URLSearchParams()
    const params = new URLSearchParams(location.search)
    const target = params.get('target')
    if (target) {
      searchParams.set('target', target)
    }

    if (status) {
      searchParams.set('status', status)
    }

    const url = new URL('/notifications', location.origin)
    url.search = searchParams

    return url.toString()
  }

  const params = new URLSearchParams(location.search)
  return (
    <nav className="pill-nav">
      <div className="container">
        <ul className="pill-nav__items">
          <li className="pill-nav__item">
            <a
              className={`pill-nav__item-link ${
                params.get('status') === 'unread' ? 'is-active' : ''
              }`}
              href={filterButtonUrl('unread')}>
              未読
            </a>
          </li>
          <li className="pill-nav__item">
            <a
              className={`pill-nav__item-link ${
                params.get('status') === 'unread' ? '' : 'is-active'
              }`}
              href={filterButtonUrl()}>
              全て
            </a>
          </li>
        </ul>
      </div>
    </nav>
  )
}

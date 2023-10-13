import React, { useState, useEffect } from 'react'
import Notification from './Notification'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Pagination from './Pagination'
import queryString from 'query-string'
import UnconfirmedLink from './UnconfirmedLink'

export default function Notifications(props) {
  const [notifications, setNotifications] = useState([])
  const [totalPages, setTotalPages] = useState(0)
  const per = 20
  const neighbours = 4

  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)
  const [loaded, setLoaded] = useState(false)

  const getPageValueFromParameter = () => {
    const url = new URL(location)
    return Number(url.searchParams.get('page')) || 1
  }

  const isUnreadPage = () => {
    const params = new URLSearchParams(location.search)
    return params.get('status') !== null && params.get('status') === 'unread'
  }

  const target = () => {
    return props.target ? `&target=${props.target}` : ''
  }

  const url = () => {
    if (isUnreadPage()) {
      return `/api/notifications.json?page=${page}&status=unread${target()}`
    } else {
      return `/api/notifications.json?page=${page}${target()}`
    }
  }

  const getNotificationsPerPage = () => {
    fetch(url(), {
      method: 'GET',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        setTotalPages(json.total_pages)
        setNotifications(json.notifications)
        console.log('json.notifications')
        console.log(json.notifications)
        setLoaded(true)
      })
      .catch((error) => {
        console.warn(error)
      })
  }
  const paginateClickCallback = (pageNumber) => {
    setPage(pageNumber)
    const url = new URL(location)
    if (pageNumber > 1) {
      url.searchParams.set('page', pageNumber)
    } else {
      url.searchParams.delete('page')
    }
    history.pushState(null, null, url)
    window.scrollTo(0, 0)
  }

  useEffect(() => {
    const handlePopstate = () => {
      console.log('page=' + page)
      setPage(getPageValueFromParameter())
    }

    window.addEventListener('popstate', handlePopstate)
    getNotificationsPerPage()
    return () => {
      window.removeEventListener('popstate', handlePopstate)
    }
  }, [page])

  let content

  if (!loaded) {
    content = (
      <div id="notifications" className="page-content loading">
        <LoadingListPlaceholder />
      </div>
    )
  } else if (notifications.length === 0) {
    content = (
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
    content = (
      <div id="notifications" className="page-content loaded">
        {totalPages > 1 && (
          <nav className="pagination">
            <Pagination
              sum={totalPages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              setPage={setPage}
              onChange={(e) => paginateClickCallback(e.page)}
            />
          </nav>
        )}
        <div className="card-list a-card">
          {notifications.map((notification) => {
            return (
              <Notification key={notification.id} notification={notification} />
            )
          })}
        </div>
        <UnconfirmedLink label="未読の通知を一括で開く" />
        {totalPages > 1 && (
          <nav className="pagination">
            <Pagination
              sum={totalPages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              setPage={setPage}
              onChange={(e) => paginateClickCallback(e.page)}
            />
          </nav>
        )}
      </div>
    )
  }

  return <>{content}</>
}

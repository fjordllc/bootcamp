import React, { useState, useEffect } from 'react'
import Notification from 'notification'
import LoadingListPlaceholder from 'loading-list-placeholder.jsx'
import Pager from 'pager.vue'
import UnconfirmedLinksOpenButton from 'unconfirmed_links_open_button'

export default function Notifications(props) {
  const [notifications, setNotifications] = useState([])
  const [totalPages, setTotalPages] = useState(0)

  const getPageValueFromParameter = () => {
    const url = new URL(location)
    return Number(url.searchParams.get('page')) || 1
  }

  const [currentPage, setCurrentPage] = useState(getPageValueFromParameter())
  const [loaded, setLoaded] = useState(false)

  const url = () => {
    if (isUnreadPage) {
      return `/api/notifications.json?page=${currentPage}&status=unread&target=${props.target}`
    } else {
      return `/api/notifications.json?page=${currentPage}&target=${props.target}`
    }
  }
  const isUnreadPage = () => {
    const params = new URLSearchParams(location.search)
    return params.get('status') !== null && params.get('status') === 'unread'
  }
  const pagerProps = () => {
    return {
      initialPageNumber: currentPage,
      pageCount: totalPages,
      pageRange: 5,
      clickHandle: paginateClickCallback
    }
  }

  const handlePopstate = () => {
    setCurrentPage(getPageValueFromParameter())
    getNotificationsPerPage()
  }

  const getNotificationsPerPage = () => {
    fetch(url, {
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
        setNotifications([])
        json.notifications.forEach((n) => {
          setNotifications(notifications.push(n))
        })
        setLoaded(true)
      })
      .catch((error) => {
        console.warn(error)
      })
  }
  const paginateClickCallback = (pageNumber) => {
    setCurrentPage(pageNumber)
    getNotificationsPerPage()
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
    window.addEventListener('popstate', handlePopstate)
    getNotificationsPerPage()

    return () => {
      window.removeEventListener('popstate', handlePopstate)
    }
  }, [])

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
            <Pager {...pagerProps} />
          </nav>
        )}
        <div className="card-list a-card">
          {notifications.map((notification) => {
            return (
              <Notification key={notification.id} notification={notification} />
            )
          })}
          {props.isMentor && isUnreadPage && (
            <UnconfirmedLinksOpenButton label="未読の通知を一括で開く" />
          )}
        </div>
        {totalPages > 1 && (
          <nav className="pagination">
            <Pager {...pagerProps} />
          </nav>
        )}
      </div>
    )
  }

  return <>{content}</>
}

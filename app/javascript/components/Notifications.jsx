import React, { useState, useEffect } from 'react'
import Notification from './Notification'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Pagination from './Pagination'
import queryString from 'query-string'
import UnconfirmedLink from './UnconfirmedLink'
import useSWR from 'swr'
import fetcher from '../fetcher'

export default function Notifications(props) {
  const target = () => {
    return props.target ? `&target=${props.target}` : ''
  }
  const getStatusQueryParam = () => {
    return queryString.parse(location.search).status || ''
  }
  const getPageQueryParam = () => {
    return parseInt(queryString.parse(location.search).page) || 1
  }
  const [statusParam, setStatusParam] = useState(getStatusQueryParam())
  const [page, setPage] = useState(getPageQueryParam())

  const isUnreadPage = () => {
    const params = new URLSearchParams(location.search)
    return params.get('status') !== null && params.get('status') === 'unread'
  }

  const url = () => {
    if (isUnreadPage()) {
      console.log(page)
      return `/api/notifications.json?page=${page}&status=unread${target()}`
    } else {
      console.log(page)
      return `/api/notifications.json?page=${page}${target()}`
    }
  }

  const { data, error } = useSWR(url, fetcher)

  const handlePaginate = (pageNumber) => {
    setPage(pageNumber)
    const url = new URL(location)
    if (pageNumber > 1) {
      url.searchParams.set('page', pageNumber)
    } else {
      url.searchParams.delete('page')
    }
    console.log('save history ' + url.href)
    window.history.pushState(null, null, url)
    window.scrollTo(0, 0)
  }

  const handlePopstate = () => {
    setStatusParam(getStatusQueryParam())
    setPage(getPageQueryParam())
  }

  window.addEventListener('popstate', handlePopstate)

  useEffect(() => {
    setStatusParam(statusParam)
    setPage(page)
  }, [statusParam, page])

  return (
    <>
      <NotificationList
        isUnreadPage={isUnreadPage}
        error={error}
        data={data}
        page={page}
        setPage={setPage}
        handlePaginate={handlePaginate}
      />
    </>
  )
}
const NotificationList = ({
  isUnreadPage,
  error,
  data,
  page,
  handlePaginate
}) => {
  const per = 20
  const neighbours = 4
  console.log('render')
  console.log('page=' + page)
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
      <div id="notifications" className="page-content loaded">
        {data.total_pages > 1 && (
          <nav className="pagination">
            <Pagination
              sum={data.total_pages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              handlePaginate={handlePaginate}
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
        <UnconfirmedLink label="未読の通知を一括で開く" />
        {data.total_pages > 1 && (
          <nav className="pagination">
            <Pagination
              sum={data.total_pages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              handlePaginate={handlePaginate}
            />
          </nav>
        )}
      </div>
    )
  }
}

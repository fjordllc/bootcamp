import React, { useState } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import queryString from 'query-string'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import RegularEvent from './RegularEvent'

const RegularEvents = () => {
  const defaultTarget = queryString.parse(location.search).target || ''
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [target, setTarget] = useState(defaultTarget)
  const [page, setPage] = useState(defaultPage)

  const handleNotFinishedClick = () => {
    setTarget('not_finished')
    setPage(1)
    window.history.pushState(null, null, '/regular_events?target=not_finished')
  }

  const handleAllClick = () => {
    setTarget('')
    setPage(1)
    window.history.pushState(null, null, '/regular_events')
  }

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(
      null,
      null,
      `/regular_events?${buildParams(target, p)}`
    )
  }

  return (
    <>
      <Navigation
        target={target}
        handleNotFinishedClick={handleNotFinishedClick}
        handleAllClick={handleAllClick}
      />
      <EventList target={target} page={page} handlePaginate={handlePaginate} />
    </>
  )
}

const Navigation = ({ target, handleNotFinishedClick, handleAllClick }) => {
  return (
    <nav className="pill-nav">
      <ul className="pill-nav__items">
        <li className="pill-nav__item">
          <button
            className={`pill-nav__item-link ${
              target === 'not_finished' ? 'is-active' : ''
            }`}
            onClick={handleNotFinishedClick}>
            開催中
          </button>
        </li>
        <li className="pill-nav__item">
          <button
            className={`pill-nav__item-link ${
              target === '' ? 'is-active' : ''
            }`}
            onClick={handleAllClick}>
            全て
          </button>
        </li>
      </ul>
    </nav>
  )
}

const EventList = ({ target, page, handlePaginate }) => {
  const per = 20
  const neighbours = 4

  const { data, error } = useSWR(
    `/api/regular_events?${buildParams(target, page)}`,
    fetcher
  )

  if (error) console.warn(error)

  if (!data) {
    return (
      <div className="page-body">
        <div className="container is-md">
          <LoadingListPlaceholder />
        </div>
      </div>
    )
  }

  return (
    <div className="page-content loaded">
      {data.total_pages > 1 && (
        <Pagination
          sum={data.total_pages * per}
          per={per}
          neighbours={neighbours}
          page={page}
          onChange={(e) => handlePaginate(e.page)}
        />
      )}
      <div className="card-list a-card">
        {data.regular_events.map((regularEvent) => (
          <RegularEvent key={regularEvent.id} regularEvent={regularEvent} />
        ))}
      </div>
      {data.total_pages > 1 && (
        <Pagination
          sum={data.total_pages * per}
          per={per}
          neighbours={neighbours}
          page={page}
          onChange={(e) => handlePaginate(e.page)}
        />
      )}
    </div>
  )
}

const buildParams = (targetParam, pageParam) => {
  const params = {
    ...(targetParam === 'not_finished' && { target: 'not_finished' }),
    page: pageParam
  }
  return new URLSearchParams(params).toString()
}

export default RegularEvents

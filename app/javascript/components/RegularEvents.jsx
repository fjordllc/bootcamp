import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import queryString from 'query-string'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import RegularEvent from './RegularEvent'

const buildParams = (targetParam, page) => {
  const target = targetParam === 'not_finished' ? 'target=not_finished&' : ''
  const pageNumber = `page=${page}`
  return `${target}${pageNumber}`
}

const RegularEvents = () => {
  const defaultTarget = queryString.parse(location.search).target || 'all'
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [targetParam, setTargetParam] = useState(defaultTarget)
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setTargetParam(targetParam)
    setPage(page)
  }, [targetParam, page])

  const { data, error } = useSWR(
    `/api/regular_events?${buildParams(targetParam, page)}`,
    fetcher
  )

  const handleNotFinishedClick = () => {
    setTargetParam('not_finished')
    setPage(1)
    window.history.pushState(null, null, '/regular_events?target=not_finished')
  }

  const handleAllClick = () => {
    setTargetParam('all')
    setPage(1)
    window.history.pushState(null, null, '/regular_events')
  }

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(
      null,
      null,
      `/regular_events?${buildParams(targetParam, p)}`
    )
  }

  return (
    <>
      <Navigation
        targetParam={targetParam}
        handleNotFinishedClick={handleNotFinishedClick}
        handleAllClick={handleAllClick}
      />
      <EventList
        error={error}
        data={data}
        page={page}
        handlePaginate={handlePaginate}
      />
    </>
  )
}

const Navigation = ({
  targetParam,
  handleNotFinishedClick,
  handleAllClick
}) => {
  return (
    <nav className="pill-nav">
      <ul className="pill-nav__items">
        <li className="pill-nav__item">
          <button
            className={`pill-nav__item-link ${
              targetParam === 'not_finished' ? 'is-active' : ''
            }`}
            onClick={handleNotFinishedClick}>
            開催中
          </button>
        </li>
        <li className="pill-nav__item">
          <button
            className={`pill-nav__item-link ${
              targetParam === 'all' ? 'is-active' : ''
            }`}
            onClick={handleAllClick}>
            全て
          </button>
        </li>
      </ul>
    </nav>
  )
}

const EventList = ({ error, data, page, handlePaginate }) => {
  const per = 20
  const neighbours = 4

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

export default RegularEvents

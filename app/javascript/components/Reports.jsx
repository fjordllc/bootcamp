import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'

export default function Reports({user, currentUser}) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])
  
  const { data, error } = useSWR(`/api/reports.json?user_id=${user.id}&page=${page}`, fetcher)
  
  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/events?page=${p}`)
  }

  if (error) return <>エラーが発生しました。</>
  if (!data) {
    return (
      <div className="container is-md">
        <LoadingListPlaceholder />
      </div>
    )
  }

  if (data.totalPages === 0){
    return <NoReports />
  } else {
    return (
      <div className="page-content reports">
        {data.totalPages > 1 && (
          <Pagination
            sum={data.totalPages * per}
            per={per}
            neighbours={neighbours}
            page={page}
            onChange={e => handlePaginate(e.page)}
          />
        )}
        <ul className="card-list a-card">
          <div className="card-list__items">
            {data.reports.map((report) => {
              return (
                <Report
                  key={report.id}
                  report={report}
                  currentUser={currentUser}
                />
              )
            })}
          </div>
        </ul>
        {data.totalPages > 1 && (
          <Pagination
            sum={data.totalPages * per}
            per={per}
            neighbours={neighbours}
            page={page}
            onChange={e => handlePaginate(e.page)}
          />
        )}
      </div>
    )
  }
}

const NoReports = () => {
  return (
    <div className="o-empty-message">
      <div className="o-empty-message__icon">
        <i className="fa-regular fa-face-sad-tear" />
        <p className="o-empty-message__text">日報はまだありません。</p>
      </div>
    </div>
  )
}

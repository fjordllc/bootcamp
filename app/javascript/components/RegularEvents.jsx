import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import queryString from 'query-string'
import Pagination from './Pagination'
import RegularEvent from './RegularEvent'

const RegularEvents = () => {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])

  const params = new URL(location.href).searchParams
  params.set('page', page)
  const { data, error } = useSWR(`/api/regular_events?${params}`, fetcher)

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/regular_events?${params}`)
  }

  if (error) console.warn(error)
  if (!data) return <div className="page-content loaing">ロード中…</div>

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
        {data.regular_events.map(regularEvent =>
          <RegularEvent
            key={regularEvent.id}
            regularEvent={regularEvent}
          />
        )}
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

import React from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import RegularEvent from './RegularEvent'

const RegularEvents = () => {
  const params = new URL(location.href).searchParams
  const { data, error } = useSWR(`/api/regular_events?${params}`, fetcher)
  if (error) console.warn(error)
  if (!data) return <div className="page-content loaing">ロード中…</div>

  return (
    <div className="page-content loaded">
      <div className="card-list a-card">
        {data.regular_events.map(regularEvent =>
          <RegularEvent
            key={regularEvent.id}
            regularEvent={regularEvent}
          />
        )}
      </div>
    </div>
  )
}

export default RegularEvents

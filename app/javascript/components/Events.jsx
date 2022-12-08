import React, { useState, useEffect } from 'react'
import queryString from 'query-string'
import useSWR from 'swr'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import UserIcon from './UserIcon'
import fetcher from '../fetcher'

export default function Events() {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])

  const { data, error } = useSWR(`/api/events?page=${page}`, fetcher)

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/events?page=${p}`)
  }

  if (error) return <>エラーが発生しました。</>
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
    <div className="page-body">
      <div className="container is-md">
        {data.total_pages > 1 && (
          <Pagination
            sum={data.total_pages * per}
            per={per}
            neighbours={neighbours}
            page={page}
            onChange={e => handlePaginate(e.page)}
          />
        )}
        <ul className="card-list a-card">
          {data.events.map((event) => {
            return (
              <Event event={event} key={event.id} />
            )
          })}
        </ul>
        {data.total_pages > 1 && (
          <Pagination
            sum={data.total_pages * per}
            per={per}
            neighbours={neighbours}
            page={page}
            onChange={e => handlePaginate(e.page)}
          />
        )}
      </div>
    </div>
  )
}

function Event({ event }) {
  return (
    <li className="card-list-item">
      <div className="card-list-item__inner">
        <div className="card-list-item__user">
          <UserIcon
            user={event.user}
            blockClassSuffix='card-list-item'
          />
        </div>
      <div className="card-list-item__rows">
        <div className="card-list-item__row">
          <div className="card-list-item-title">
            {event.wip ? (
              <div className="a-list-item-badge is-wip">
                <span>WIP</span>
              </div>
            ) : event.ended && (
              <div className="a-list-item-badge is-ended">
                <span>終了</span>
              </div>
            )}
              <h2 className="card-list-item-title__title" itemProp="name">
                <a className="card-list-item-title__link a-text-link" href={event.url} itemProp="url">
                  { event.title }
                </a>
              </h2>
            </div>
          </div>
        <div className="card-list-item__row">
          <a className="a-user-name" href={event.user.url}>
            { event.user.long_name }
          </a>
        </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <div className="card-list-item-meta__item"><time className="a-meta" dateTime={event.start_at}>
                  <span className="a-meta__label">開催日時</span><span className="a-meta__value">{ event.start_at_localized }</span>
                  </time>
                </div>
                  <div className="card-list-item-meta__item">
                    <div className="a-meta">
                      参加者（{ event.participants_count }名 / { event.capacity }名）
                    </div>
                  </div>
                  {event.waitlist_count > 0 && (
                    <div className="card-list-item-meta__item">
                      <div className="a-meta">補欠者（{ event.waitlist_count }名）</div>
                    </div>
                  )}
                  {event.comments_count > 0 && (
                    <div className="card-list-item-meta__item">
                      <div className="a-meta">コメント（{ event.comments_count }）</div>
                    </div>
                  )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </li>
  )
}

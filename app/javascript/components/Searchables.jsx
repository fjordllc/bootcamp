import React from 'react'
import useSWR from 'swr'
import usePage from './hooks/usePage'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Searchable from './Searchable'
import fetcher from '../fetcher'

export default function Searchables({ word }) {
  const per = 50
  const { page, setPage } = usePage()
  const params = new URLSearchParams(location.search)
  const url = `/api/searchables.json?${params}`
  const { data, error } = useSWR(url, fetcher)

  if (error) {
    console.warn(error)
    return <div>failed to load</div>
  }

  return (
    <div className="page-body">
      {!data && (
        <div className="container is-md">
          <LoadingListPlaceholder />
        </div>
      )}

      {data?.searchables.length === 0 && (
        <div className="container">
          <div className="a-empty-message">
            <div className="a-empty-message__icon">
              <i className="fa-regular fa-sad-tear" />
            </div>
            <p className="a-empty-message__text">
              {word}に一致する情報は見つかりませんでした。
            </p>
          </div>
        </div>
      )}

      {data && data.searchables.length > 0 && (
        <div className="container is-md">
          {data.total_pages > 1 && (
            <nav className="pagination">
              <Pagination
                sum={data.total_pages * per}
                per={per}
                neighbours={2}
                page={page}
                setPage={setPage}
              />
            </nav>
          )}
          <div className="card-list a-card">
            {data.searchables.map((searchable) => (
              <Searchable
                key={searchable.url}
                searchable={searchable}
                word={word}
              />
            ))}
          </div>
          {data.total_pages > 1 && (
            <nav className="pagination">
              <Pagination
                sum={data.total_pages * per}
                per={per}
                neighbours={2}
                page={page}
                setPage={setPage}
              />
            </nav>
          )}
        </div>
      )}
    </div>
  )
}

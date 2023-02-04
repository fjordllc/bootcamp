import React, { useState, useEffect } from 'react'
import queryString from 'query-string'
import useSWR from 'swr'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Product from './Product'
import fetcher from '../fetcher'

export default function Products() {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])

  // const { data, error } = useSWR(`/api/events?page=${page}`, fetcher)
  const { data, error } = useSWR(`/api/products?page=${page}`, fetcher)
  console.log(data)

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/products?page=${p}`)
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
          {data.products.map((product) => {
            return (
              <Product product={product} key={product.id} />
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

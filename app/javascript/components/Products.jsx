import React, { useState, useEffect } from 'react'
import queryString from 'query-string'
import useSWR from 'swr'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Product from './Product'
import fetcher from '../fetcher'

export default function Products({ title, selectedTab }) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])

  const url = (() => {
    if (selectedTab === 'all') return '';
    if (selectedTab === 'unassigned') return '/unassigned';
    if (selectedTab === 'unchecked') return '/unchecked';
    if (selectedTab === 'self_assigned') return '/self_assigned';
  })()

  const { data, error } = useSWR(`/api/products${url}?page=${page}`, fetcher)

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/products${url}?page=${p}`)
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

  if (data.products.length === 0) {
    return (
      <div class="o-empty-message">
        <div class="o-empty-message__icon">
          <i class="fa-regular fa-smile"></i>
        </div>
        <p class="o-empty-message__text">{title}はありません</p>
      </div>
    )
  } else {
    return (
      <div className="page-body">
        <div className="container is-md">
          {data.total_pages > 1 && (
            <Pagination
              sum={data.total_pages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              onChange={(e) => handlePaginate(e.page)}
            />
          )}
          <ul className="card-list a-card">
            {data.products.map((product) => {
              return <Product product={product} key={product.id} />
            })}
          </ul>
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
      </div>
    )
  }
}

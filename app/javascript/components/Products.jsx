import React, { useState, useEffect } from 'react'
import queryString from 'query-string'
import useSWR from 'swr'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import UserIcon from './UserIcon'
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

function Product({ product }) {
  return (
    <li className="card-list-item">
      <div className="card-list-item__inner">
        <div className="card-list-item__user">
          <UserIcon
            user={product.user}
            blockClassSuffix='card-list-item'
          />
        </div>
      <div className="card-list-item__rows">
        <div className="card-list-item__row">
          <div className="card-list-item-title">
            {product.wip ? (
              <div className="a-list-item-badge is-wip">
                <span>WIP</span>
              </div>
            ) : product.ended && (
              <div className="a-list-item-badge is-ended">
                <span>終了</span>
              </div>
            )}
              <h2 className="card-list-item-title__title" itemProp="name">
                <a className="card-list-item-title__link a-text-link" href={product.url} itemProp="url">
                  { product.practice.title }の提出物
                </a>
              </h2>
            </div>
          </div>
        <div className="card-list-item__row">
          <a className="a-user-name" href={product.user.url}>
            { product.user.long_name }
          </a>
        </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <div className="card-list-item-meta__item"><time className="a-meta" dateTime={product.created_at}>
                  <span className="a-meta__label">提出</span><span className="a-meta__value">{ product.created_at }</span>
                  </time>
                </div>
                <div className="card-list-item-meta__item"><time className="a-meta" dateTime={product.updated_at}>
                  <span className="a-meta__label">更新</span><span className="a-meta__value">{ product.updated_at }</span>
                  </time>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </li>
  )
}

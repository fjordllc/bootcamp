import React from 'react'
import useSWR from 'swr'
import Pagination from './Pagination'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import UnconfirmedLink from './UnconfirmedLink'
import Product from './Product'
import fetcher from '../fetcher'
import ElapsedDays from './ElapsedDays'
import usePage from './hooks/usePage'

export default function Products({
  title,
  selectedTab,
  isMentor,
  currentUserId
}) {
  const { page, setPage } = usePage()

  const unconfirmedLinksName = () => {
    if (selectedTab === 'all') return '全ての提出物を一括で開く'
    if (selectedTab === 'unchecked') return '未完了の提出物を一括で開く'
    if (selectedTab === 'unassigned') return '未アサインの提出物を一括で開く'
    if (selectedTab === 'self_assigned') return '自分の担当の提出物を一括で開く'
  }

  const ApiUrl = () => {
    const path = (() => {
      if (selectedTab === 'all') return ''
      if (selectedTab === 'unassigned') return '/unassigned'
      if (selectedTab === 'unchecked') return '/unchecked'
      if (selectedTab === 'self_assigned') return '/self_assigned'
    })()
    const params = new URLSearchParams(location.search)

    return `/api/products${path}?${params}`
  }

  const isDashboard = () => {
    return location.pathname === '/'
  }

  const { data, error } = useSWR(ApiUrl(), fetcher)

  const getElementNdaysPassed = (elapsedDays, productsGroupedByElapsedDays) => {
    const element = productsGroupedByElapsedDays.find(
      (el) => el.elapsed_days === elapsedDays
    )
    return element
  }

  const countProductsGroupedBy = (elapsedDays) => {
    const element = getElementNdaysPassed(
      elapsedDays,
      data.products_grouped_by_elapsed_days
    )
    return element === undefined ? 0 : element.products.length
  }

  const isNotProduct5daysElapsed = () => {
    const elapsedDays = []
    data.productsGroupedByElapsedDays.forEach((group) => {
      elapsedDays.push(group.elapsed_days)
    })
    return elapsedDays.every((day) => day < 5)
  }
  const elapsedDaysId = (elapsedDays) => {
    return `${elapsedDays}days-elapsed`
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
  } else if (data.products.length === 0) {
    return (
      <>
        {selectedTab === 'unchecked' || selectedTab === 'self_assigned' ? (
          <nav className="pill-nav">
            <ul className="pill-nav__items">
              <FilterButtons selectedTab={selectedTab} />
            </ul>
          </nav>
        ) : null}

        <div className="o-empty-message">
          <div className="o-empty-message__icon">
            <i className="fa-regular fa-smile"></i>
          </div>
          <p className="o-empty-message__text">{title}はありません</p>
        </div>
      </>
    )
  } else if (isDashboard() && isNotProduct5daysElapsed()) {
    return (
      <div className="o-empty-message">
        <div className="o-empty-message__icon">
          <i className="fa-regular fa-smile" />
        </div>
        <p className="o-empty-message__text">5日経過した提出物はありません</p>
      </div>
    )
  } else if (selectedTab !== 'unassigned') {
    const per = 50
    return (
      <>
        {selectedTab !== 'all' && (
          <nav className="pill-nav">
            <ul className="pill-nav__items">
              <FilterButtons selectedTab={selectedTab} />
            </ul>
          </nav>
        )}

        <div className="page-content is-products">
          <div className="page-body__columns">
            <div className="page-body__column is-main">
              <div className="container is-md">
                {data.total_pages > 1 && (
                  <Pagination
                    sum={data.total_pages * per}
                    per={per}
                    page={page}
                    setPage={setPage}
                  />
                )}
                <ul className="card-list a-card">
                  {data.products.map((product) => {
                    return (
                      <Product
                        product={product}
                        key={product.id}
                        isMentor={isMentor}
                        currentUserId={currentUserId}
                      />
                    )
                  })}
                </ul>
                {data.total_pages > 1 && (
                  <Pagination
                    sum={data.total_pages * per}
                    per={per}
                    page={page}
                    setPage={setPage}
                  />
                )}
                <UnconfirmedLink label={unconfirmedLinksName()} />
              </div>
            </div>
          </div>
        </div>
      </>
    )
  } else {
    return (
      <div className="page-content is-products">
        <div className="page-body__columns">
          <div className="page-body__column is-main">
            {data.products_grouped_by_elapsed_days.map(
              (productsNDaysPassed) => {
                return (
                  <div
                    className="a-card"
                    key={productsNDaysPassed.elapsed_days}>
                    <ProductHeader
                      productsNDaysPassed={productsNDaysPassed}
                      elapsedDaysId={elapsedDaysId}
                      countProductsGroupedBy={countProductsGroupedBy}
                    />
                    <div className="card-list">
                      <div className="card-list__items">
                        {productsNDaysPassed.products.map((product) => {
                          return (
                            <Product
                              product={product}
                              key={product.id}
                              isMentor={isMentor}
                              currentUserId={currentUserId}
                              elapsedDays={productsNDaysPassed.elapsed_days}
                            />
                          )
                        })}
                      </div>
                    </div>
                  </div>
                )
              }
            )}
            <UnconfirmedLink label={unconfirmedLinksName()} />
          </div>

          <ElapsedDays countProductsGroupedBy={countProductsGroupedBy} />
        </div>
      </div>
    )
  }
}

function ProductHeader({
  productsNDaysPassed,
  elapsedDaysId,
  countProductsGroupedBy
}) {
  let headerClass = 'card-header a-elapsed-days'
  if (productsNDaysPassed.elapsed_days === 5) {
    headerClass += ' is-reply-warning'
  } else if (productsNDaysPassed.elapsed_days === 6) {
    headerClass += ' is-reply-alert'
  } else if (productsNDaysPassed.elapsed_days >= 7) {
    headerClass += ' is-reply-deadline'
  }

  const headerLabel = () => {
    if (productsNDaysPassed.elapsed_days === 0) {
      return '今日提出'
    } else if (productsNDaysPassed.elapsed_days === 7) {
      return `${productsNDaysPassed.elapsed_days}日以上経過`
    } else {
      return `${productsNDaysPassed.elapsed_days}日経過`
    }
  }

  return (
    <header
      className={headerClass}
      id={elapsedDaysId(productsNDaysPassed.elapsed_days)}>
      <h2 className="card-header__title">
        {headerLabel()}
        <span className="card-header__count">
          （{countProductsGroupedBy(productsNDaysPassed.elapsed_days)}）
        </span>
      </h2>
    </header>
  )
}

const FilterButtons = ({ selectedTab }) => {
  let targets
  if (selectedTab === 'self_assigned') {
    targets = ['self_assigned_all', 'self_assigned_no_replied']
  } else {
    targets = ['unchecked_all', 'unchecked_no_replied']
  }

  const filterButtonUrl = ({ selectedTab, target }) => {
    const searchParams = new URLSearchParams()
    const params = new URLSearchParams(location.search)

    const id = params.get('checker_id')
    if (id) {
      searchParams.set('checker_id', id)
    }
    searchParams.set('target', target)
    const url = new URL(
      new URL(`/products/${encodeURIComponent(selectedTab)}`, location.origin)
    )
    url.search = searchParams

    return url.toString()
  }

  const isActive = (target) => {
    const params = new URLSearchParams(location.search)
    const urlTarget = params.get('target')
    if (!urlTarget) {
      if (target === 'unchecked_all' || target === 'self_assigned_all') {
        return 'is-active'
      }
    } else if (target === urlTarget) {
      return 'is-active'
    } else {
      return ''
    }
  }

  return (
    <>
      {targets.map((target) => {
        return (
          <li className="pill-nav__item" key={target}>
            <a
              href={filterButtonUrl({ selectedTab, target })}
              className={`pill-nav__item-link ${isActive(target)}`}>
              {target === 'unchecked_no_replied' ||
              target === 'self_assigned_no_replied'
                ? '未返信'
                : '全て'}
            </a>
          </li>
        )
      })}
    </>
  )
}

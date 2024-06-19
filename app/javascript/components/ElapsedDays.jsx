import React from 'react'

export default function ElapsedDays({
  countProductsGroupedBy,
  productDeadlineDay
}) {
  const activeClass = (quantity) => {
    return quantity ? 'is-active' : 'is-inactive'
  }

  return (
    <nav className="page-body__column is-sub">
      <div className="page-nav a-card">
        <ol className="page-nav__items elapsed-days">
          <li
            className={`page-nav__item is-reply-deadline border-b-0 ${activeClass(
              countProductsGroupedBy(productDeadlineDay + 2)
            )}`}>
            <a className="page-nav__item-link" href="#deadline-alert">
              <span className="page-nav__item-link-inner">
                {productDeadlineDay + 2}日以上経過
                {` (${countProductsGroupedBy(productDeadlineDay + 2)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-alert border-b-0 ${activeClass(
              countProductsGroupedBy(productDeadlineDay + 1)
            )}`}>
            <a className="page-nav__item-link" href="#second-alert">
              <span className="page-nav__item-link-inner">
                {productDeadlineDay + 1}日経過
                {` (${countProductsGroupedBy(productDeadlineDay + 1)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-warning border-b-0 ${activeClass(
              countProductsGroupedBy(productDeadlineDay)
            )}`}>
            <a className="page-nav__item-link" href="#first-alert">
              <span className="page-nav__item-link-inner">
                {productDeadlineDay}日経過
                {` (${countProductsGroupedBy(productDeadlineDay)})`}
              </span>
            </a>
          </li>
          {Array.from(
            { length: productDeadlineDay - 1 },
            (_, index) => index + 1
          )
            .reverse()
            .map((passedDay) => {
              return (
                <li
                  key={passedDay}
                  className={`page-nav__item ${activeClass(
                    countProductsGroupedBy(passedDay)
                  )}`}>
                  <a
                    href={`#${passedDay}days-elapsed`}
                    className="page-nav__item-link">
                    <span className="page-nav__item-link-inner">
                      {passedDay}日経過
                      {` (${countProductsGroupedBy(passedDay)})`}
                    </span>
                  </a>
                </li>
              )
            })}
          <li
            className={`page-nav__item ${activeClass(
              countProductsGroupedBy(0)
            )}`}>
            <a href="#0days-elapsed" className="page-nav__item-link">
              <span className="page-nav__item-link-inner">
                今日提出{` (${countProductsGroupedBy(0)})`}
              </span>
            </a>
          </li>
        </ol>
      </div>
    </nav>
  )
}

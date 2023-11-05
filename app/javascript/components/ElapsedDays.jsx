import React from 'react'

export default function ElapsedDays({ countProductsGroupedBy }) {
  const activeClass = (quantity) => {
    return quantity ? 'is-active' : 'is-inactive'
  }

  return (
    <nav className="page-body__column is-sub">
      <div className="page-nav">
        <ol className="page-nav__items elapsed-days">
          <li
            className={`page-nav__item is-reply-deadline ${activeClass(
              countProductsGroupedBy(7)
            )}`}>
            <a className="page-nav__item-link" href="#7days-elapsed">
              <span className="page-nav__item-link-inner">
                7日以上経過{` (${countProductsGroupedBy(7)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-alert ${activeClass(
              countProductsGroupedBy(6)
            )}`}>
            <a className="page-nav__item-link" href="#6days-elapsed">
              <span className="page-nav__item-link-inner">
                6日経過{` (${countProductsGroupedBy(6)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-warning ${activeClass(
              countProductsGroupedBy(5)
            )}`}>
            <a className="page-nav__item-link" href="#5days-elapsed">
              <span className="page-nav__item-link-inner">
                5日経過{` (${countProductsGroupedBy(5)})`}
              </span>
            </a>
          </li>
          {[4, 3, 2, 1].map((passedDay) => {
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

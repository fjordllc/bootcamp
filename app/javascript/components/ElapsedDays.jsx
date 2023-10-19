import React from 'react'

export default function ElapsedDays({
  productsGroupedByElapsedDays,
  countProductsGroupedBy
}) {
  const countProductsByElapsedDays = (elapsedDays) => {
    const productsGroup = productsGroupedByElapsedDays.find((product) => {
      return product.elapsed_days === elapsedDays
    })
    if (productsGroup)
      return countProductsGroupedBy(
        productsGroup.elapsed_days,
        productsGroup.products
      )
    return countProductsGroupedBy(0, [])
  }
  const activeClass = (quantity) => {
    if (quantity) return `is-active`
    return `is-inactive`
  }

  return (
    <nav className="page-body__column is-sub">
      <div className="page-nav">
        <ol className="page-nav__items elapsed-days">
          <li
            className={`page-nav__item is-reply-deadline ${activeClass(
              countProductsByElapsedDays(7)
            )}`}>
            <a className="page-nav__item-link" href="#7days-elapsed">
              <span className="page-nav__item-link-inner">
                7日以上経過{` (${countProductsByElapsedDays(7)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-alert ${activeClass(
              countProductsByElapsedDays(6)
            )}`}>
            <a className="page-nav__item-link" href="#6days-elapsed">
              <span className="page-nav__item-link-inner">
                6日経過{` (${countProductsByElapsedDays(6)})`}
              </span>
            </a>
          </li>
          <li
            className={`page-nav__item is-reply-warning ${activeClass(
              countProductsByElapsedDays(5)
            )}`}>
            <a className="page-nav__item-link" href="#6days-elapsed">
              <span className="page-nav__item-link-inner">
                5日経過{` (${countProductsByElapsedDays(5)})`}
              </span>
            </a>
          </li>
          {[4, 3, 2, 1].map((passedDay) => {
            return (
              <li
                key={passedDay}
                className={`page-nav__item ${activeClass(
                  countProductsByElapsedDays(passedDay)
                )}`}>
                <a
                  href={`#${passedDay}days-elapsed`}
                  className="page-nav__item-link">
                  <span className="page-nav__item-link-inner">
                    {passedDay}日経過
                    {` (${countProductsByElapsedDays(passedDay)})`}
                  </span>
                </a>
              </li>
            )
          })}
          <li
            className={`page-nav__item ${activeClass(
              countProductsByElapsedDays(0)
            )}`}>
            <a href="#0days-elapsed" className="page-nav__item-link">
              <span className="page-nav__item-link-inner">
                今日提出{` (${countProductsByElapsedDays(0)})`}
              </span>
            </a>
          </li>
        </ol>
      </div>
    </nav>
  )
}

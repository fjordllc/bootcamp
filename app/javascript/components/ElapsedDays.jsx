import React from 'react'

export default function ElapsedDays({
  countProductsGroupedBy,
  productDeadlineDay
}) {
  const activeClass = (quantity) => {
    return quantity ? 'is-active' : 'is-inactive'
  }

  const renderElapsedDay = (elapsedDays, linkHref, linkText, alertText) => {
    return (
      <li
        className={`page-nav__item is-reply-${linkText} border-b-0 ${activeClass(
          countProductsGroupedBy(productDeadlineDay + elapsedDays)
        )}`}>
        <a className="page-nav__item-link" href={`#${linkHref}`}>
          <span className="page-nav__item-link-inner">
            {productDeadlineDay + elapsedDays}日{alertText}経過
            {` (${countProductsGroupedBy(productDeadlineDay + elapsedDays)})`}
          </span>
        </a>
      </li>
    )
  }

  return (
    <nav className="page-body__column is-sub">
      <div className="page-nav a-card">
        <ol className="page-nav__items elapsed-days">
          {renderElapsedDay(+2, 'deadline-alert', 'deadline', '以上')}
          {renderElapsedDay(+1, 'second-alert', 'alert')}
          {renderElapsedDay(0, 'first-alert', 'warning')}
          {Array.from(
            { length: productDeadlineDay - 1 },
            (_, index) => index + 1
          )
            .reverse()
            .map((passedDay) => (
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
            ))}
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

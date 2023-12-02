import React from "react"
import dayjs from "dayjs"

const clientDateFormat = 'YYYY年M月'

export default function GrassNav ({ onAddOneYear, currentDate, onSubtractOneYear }) {
  const prevYearMonth = dayjs(currentDate).subtract(1, 'year')
  const isLatestYearMonth = dayjs().isSame(currentDate, 'month')
  return (
    <div className="user-grass-nav">
      <div className="user-grass-nav__previous" onClick={onSubtractOneYear}>
        <i className="fa-solid fa-angle-left" />
      </div>
      <div className="user-grass-nav__year--month">
        {prevYearMonth?.format(clientDateFormat)} 〜
        {currentDate?.format(clientDateFormat)}
      </div>
      {!isLatestYearMonth ? (
        <div className="user-grass-nav__next" onClick={onAddOneYear}>
          <i className="fa-solid fa-angle-right" />
        </div>
      ) : (
        <div className="user-grass-nav__next is-blank" />
      )}
    </div>
  )
}

import React from 'react'
import Report from './Report'
import UnconfirmedLink from '../UnconfirmedLink'

export default function Reports({
  totalPages,
  reports,
  pagination,
  practices,
  unchecked,
  displayUserIcon = true,
  displayPagination = true
}) {
  return (
    <div>
      {practices}
      {totalPages === 0 && <NoReports unchecked={unchecked} />}
      {totalPages > 0 && (
        <div className="page-content reports">
          {totalPages > 1 && displayPagination && pagination}
          <ul className="card-list a-card">
            <div className="card-list__items">
              {reports.map((report) => {
                return (
                  <Report
                    key={report.id}
                    report={report}
                    currentUserId={report.currentUserId}
                    displayUserIcon={displayUserIcon}
                  />
                )
              })}
            </div>
          </ul>
          {unchecked && (
            <UnconfirmedLink label={'未チェックの日報を一括で開く'} />
          )}
          {totalPages > 1 && displayPagination && pagination}
        </div>
      )}
    </div>
  )
}

const NoReports = ({ unchecked }) => {
  return (
    <div className="o-empty-message">
      <div className="o-empty-message__icon">
        {unchecked ? (
          <>
            <i className="fa-regular fa-smile" />
            <p className="o-empty-message__text">
              未チェックの日報はありません
            </p>
          </>
        ) : (
          <>
            <i className="fa-regular fa-sad-tear" />
            <p className="o-empty-message__text">日報はまだありません。</p>
          </>
        )}
      </div>
    </div>
  )
}

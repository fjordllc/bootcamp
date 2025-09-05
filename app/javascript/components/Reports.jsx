import React, { useState } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'
import PracticeFilterDropdown from './PracticeFilterDropdown'
import UnconfirmedLink from './UnconfirmedLink'
import usePage from './hooks/usePage'

export default function Reports({
  userId = '',
  practices = false,
  unchecked = false,
  displayUserIcon = true,
  companyId = '',
  practiceId = '',
  displayPagination = true
}) {
  const per = 20
  const { page, setPage } = usePage()
  const [userPracticeId, setUserPracticeId] = useState('')

  let reportsUrl = `/api/reports.json?page=${page}`
  if (userId) reportsUrl += `&user_id=${userId}`
  if (companyId) reportsUrl += `&company_id=${companyId}`
  const pid = userPracticeId || practiceId
  if (pid) reportsUrl += `&practice_id=${pid}`
  if (unchecked) reportsUrl += `&target=unchecked_reports`

  const { data, error } = useSWR(reportsUrl, fetcher)

  if (error) return <>エラーが発生しました。</>
  if (!data) {
    return (
      <div className="page-main">
        <div className="page-body">
          <div className="container is-md">
            <LoadingListPlaceholder />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="page-main is-react">
      {data.totalPages === 0 && (
        <div>
          {practices && (
            <PracticeFilterDropdown
              practices={practices}
              setPracticeId={setUserPracticeId}
              practiceId={userPracticeId}
            />
          )}
          <NoReports unchecked={unchecked} />
        </div>
      )}
      {data.totalPages > 0 && (
        <div>
          {practices && (
            <PracticeFilterDropdown
              practices={practices}
              setPracticeId={setUserPracticeId}
              practiceId={userPracticeId}
            />
          )}
          <div className="page-body">
            <div className="container is-md">
              <div className="page-content reports">
                {data.totalPages > 1 && displayPagination && (
                  <Pagination
                    sum={data.totalPages * per}
                    per={per}
                    page={page}
                    setPage={setPage}
                  />
                )}
                <div className="card-list a-card">
                  <div className="card-list__items">
                    {data.reports.map((report) => {
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
                  {unchecked && (
                    <UnconfirmedLink label={'未チェックの日報を一括で開く'} />
                  )}
                </div>
                {data.totalPages > 1 && displayPagination && (
                  <Pagination
                    sum={data.totalPages * per}
                    per={per}
                    page={page}
                    setPage={setPage}
                  />
                )}
              </div>
            </div>
          </div>
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
          <div className="card-list">
            <div className="card-body">
              <div className="card-body__description">
                <div className="o-empty-message">
                  <div className="o-empty-message__icon">
                    <i className="fa-regular fa-sad-tear" />
                  </div>
                  <p className="o-empty-message__text">
                    日報はまだありません。
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

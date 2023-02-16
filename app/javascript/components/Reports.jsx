import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'
import PracticeFilterDropdown from './PracticeFilterDropdown'
import UnconfirmedLink from './UnconfirmedLink'

export default function Reports({all = false, userId = '', practices = false, unchecked = false, displayUserIcon = true, companyId = '', practiceId = ''}) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)
  const [userPracticeId, setUserPracticeId] = useState('')

  useEffect(() => {
    setPage(page)
  }, [page])

  useEffect(() => {
    setUserPracticeId(userPracticeId)
  }, [userPracticeId])

  const { data, error } = useSWR(
    unchecked
    ? `/api/reports/unchecked.json?page=${page}&user_id=${userId}`
    : userId !== ''
    ? `/api/reports.json?page=${page}&user_id=${userId}`
    : practiceId !== ''
    ? `/api/reports.json?page=${page}&practice_id=${practiceId}`
    : companyId !== ''
    ? `/api/reports.json?page=${page}&company_id=${companyId}`
    : practices
    ? `/api/reports.json?user_id=${userId}&page=${page}&practice_id=${userPracticeId}`
    : all === true
    ? `/api/reports.json?page=${page}&practice_id=${userPracticeId}`
    : console.log('data_fetched!'),
    fetcher
  )

  if (error) return <>エラーが発生しました。</>
  if (!data) {
    return (
      <div className="container is-md">
        <LoadingListPlaceholder />
      </div>
    )
  }

  return (
    <>
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
          <div className="page-content reports">
            {data.totalPages > 1 && (
              <Pagination
                sum={data.totalPages * per}
                per={per}
                neighbours={neighbours}
                page={page}
                onChange={(e) => setPage(e.page)}
              />
            )}
            <ul className="card-list a-card">
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
            </ul>
            { unchecked && (
              <UnconfirmedLink label={'未チェックの日報を一括で開く'} />
            )}
            {data.totalPages > 1 && (
              <Pagination
                sum={data.totalPages * per}
                per={per}
                neighbours={neighbours}
                page={page}
                onChange={(e) => setPage(e.page)}
              />
            )}
          </div>
        </div>
      )}
    </>
  )
}

const NoReports = ({unchecked}) => {
  return (
    <div className="o-empty-message">
      <div className="o-empty-message__icon">
      {unchecked
        ? <><i className="fa-regular fa-smile" /><p className="o-empty-message__text">未チェックの日報はありません</p></>
        : <><i className="fa-regular fa-sad-tear" /><p className="o-empty-message__text">'日報はまだありません'</p></>
      }
      </div>
    </div>
  )
}

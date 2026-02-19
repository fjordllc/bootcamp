import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import { get } from '@rails/request.js'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'
import usePage from './hooks/usePage'
const fetcher = (url) =>
  get(url, { responseKind: 'json' }).then((res) => res.json)

export default function Reports({
  userId = '',
  practices = false,
  unchecked = false,
  displayUserIcon = true,
  companyId = '',
  practiceId = '',
  displayPagination = true,
  isGrantCourse = false
}) {
  const per = 20
  const { page, setPage } = usePage()
  const [selectedPracticeId, setSelectedPracticeId] = useState('')
  const [withGrant, setWithGrant] = useState(false)

  let reportsUrl = `/api/reports.json?page=${page}`
  if (userId) reportsUrl += `&user_id=${userId}`
  if (companyId) reportsUrl += `&company_id=${companyId}`
  const pid = selectedPracticeId || practiceId
  if (pid) reportsUrl += `&practice_id=${pid}`
  if (unchecked) reportsUrl += `&target=unchecked_reports`
  if (isGrantCourse && withGrant) reportsUrl += `&with_grant=true`

  const { data, error } = useSWR(reportsUrl, fetcher)

  useEffect(() => {
    if (!data || !practices) return

    let dropdown = null
    const initDropdown = async () => {
      const targetElement = document.querySelector(
        '[data-practice-filter-dropdown]'
      )
      if (!targetElement || dropdown) return

      const PracticeFilterDropdown = (
        await import('../practice-filter-dropdown')
      ).default
      dropdown = new PracticeFilterDropdown(
        practices,
        selectedPracticeId,
        setSelectedPracticeId
      )
      dropdown.render(targetElement)
    }

    initDropdown()

    return () => {
      if (dropdown) {
        dropdown.destroy()
        dropdown = null
      }
    }
  }, [data, practices, setSelectedPracticeId])

  useEffect(() => {
    if (!isGrantCourse) return

    let grantFilter = null
    const initGrantFilter = async () => {
      const targetElement = document.querySelector('[data-grant-filter]')
      if (!targetElement) return

      const GrantFilter = (await import('../grant-filter')).default
      grantFilter = new GrantFilter(withGrant, setWithGrant)
      grantFilter.render(targetElement)
    }
    initGrantFilter()

    return () => {
      if (grantFilter) {
        grantFilter.destroy()
        grantFilter = null
      }
    }
  }, [data, withGrant])

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
          {isGrantCourse && <div data-grant-filter></div>}
          {practices && <div data-practice-filter-dropdown></div>}
          <NoReports unchecked={unchecked} />
        </div>
      )}
      {data.totalPages > 0 && (
        <div>
          {isGrantCourse && <div data-grant-filter></div>}
          {practices && <div data-practice-filter-dropdown></div>}
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

import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../../fetcher'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import Reports from './Reports'
import Pagination from '../Pagination'
import PracticeFilterDropdown from './PracticeFilterDropdown'

export default function PracticesReports({
  practices,
  displayUserIcon = true,
  displayPagination = true
}) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)
  const [selectedPracticeId, setSelectedPracticeId] = useState('')

  useEffect(() => {
    setPage(page)
    window.history.pushState(
      null,
      null,
      `/reports?page=${page}${
        selectedPracticeId ? `&practice_id=${selectedPracticeId}` : ''
      }`
    )
  }, [page, selectedPracticeId])

  useEffect(() => {
    setSelectedPracticeId(selectedPracticeId)
  }, [selectedPracticeId])

  const { data, error } = useSWR(
    `/api/reports.json?page=${page}&practice_id=${selectedPracticeId}`,
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
    <Reports
      totalPages={data.totalPages}
      reports={data.reports}
      practices={
        <PracticeFilterDropdown
          practices={practices}
          setPracticeId={setSelectedPracticeId}
          practiceId={selectedPracticeId}
        />
      }
      displayUserIcon={displayUserIcon}
      displayPagination={displayPagination}
      pagination={
        <Pagination
          sum={data.totalPages * per}
          per={per}
          neighbours={neighbours}
          page={page}
          onChange={(e) => setPage(e.page)}
        />
      }
    />
  )
}

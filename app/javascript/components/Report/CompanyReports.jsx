import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../../fetcher'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import Reports from './Reports'
import Pagination from '../Pagination'

export default function CompanyReports({ companyId }) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
    window.history.pushState(
      null,
      null,
      `/reports?page=${page}&company_id=${companyId}`
    )
  }, [page])

  const { data, error } = useSWR(
    `/api/reports.json?page=${page}&company_id=${companyId}`,
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

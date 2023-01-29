import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'

export default function Reports({user, currentUser, practices}) {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)
  const [practiceId, setPracticeId] = useState('')

  useEffect(() => {
    setPage(page)
  }, [page])

  useEffect(() => {
    setPracticeId(practiceId)
  }, [practiceId])
  
  const { data, error } = useSWR(`/api/reports.json?user_id=${user.id}&page=${page}&practice_id=${practiceId}`, fetcher)
  
  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/events?page=${p}`)
  }

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
      <DropDown
        practices={practices}
        setPracticeId={setPracticeId}
      />
      {(data.totalPages === 0) && <NoReports />}
      {(data.totalPages > 0) && (
        <div className="container is-md">
        <div className="page-content reports">
          {data.totalPages > 1 && (
            <Pagination
              sum={data.totalPages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              onChange={e => handlePaginate(e.page)}
            />
          )}
          <ul className="card-list a-card">
            <div className="card-list__items">
              {data.reports.map((report) => {
                return (
                  <Report
                    key={report.id}
                    report={report}
                    currentUser={currentUser}
                  />
                )
              })}
            </div>
          </ul>
          {data.totalPages > 1 && (
            <Pagination
              sum={data.totalPages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              onChange={e => handlePaginate(e.page)}
            />
          )}
        </div>
      </div>
      )
      }
    </>
  )
}

const NoReports = () => {
  return (
    <div className="o-empty-message">
      <div className="o-empty-message__icon">
        <i className="fa-regular fa-face-sad-tear" />
        <p className="o-empty-message__text">日報はまだありません。</p>
      </div>
    </div>
  )
}

const DropDown = ({practices, setPracticeId}) => {
  const [selectValue, setSelectValue] = useState('');
  const onChange = (event) => {
    const value = event.target.value
    setSelectValue(value)
    setPracticeId(value)
  };
  return (
    <>
      <nav className="page-filter form">
        <div className="container is-md">
          <div className="form-item is-inline-md-up">
            <label className="a-form-label" htmlFor="js-choices-single-select">プラクティスで絞り込む</label>
            <select
              id="js-choices-single-select"
              className="a-form-select choices__input"
              onChange={onChange}
            >
              <option key="" value="">全ての日報を表示</option>
              {practices.map((practice) => {
                return (
                  <option key={practice.id} value={practice.id}>{practice.title}</option>
                )
              })}
            </select>
          </div>
        </div>
      </nav>
    </>
  )
}

import React, { useState, useEffect, useRef } from 'react'
import useSWR from 'swr'
import queryString from 'query-string'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'
import Report from './Report'
import Pagination from './Pagination'
import Choices from "choices.js";

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
      {(data.totalPages === 0) && (
        <div className="container is-md">
          <DropDown
            practices={practices}
            setPracticeId={setPracticeId}
            practiceId={practiceId}
          />
          <NoReports />
        </div>
      )}
      {(data.totalPages > 0) && (
        <div className="container is-md">
        <DropDown
          practices={practices}
          setPracticeId={setPracticeId}
          practiceId={practiceId}
        />
        <div className="page-content reports">
          {data.totalPages > 1 && (
            <Pagination
              sum={data.totalPages * per}
              per={per}
              neighbours={neighbours}
              page={page}
              onChange={e => setPage(e.page)}
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
              onChange={e => setPage(e.page)}
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

const DropDown = ({practices, setPracticeId, practiceId}) => {
  const [selectedId, setSelectedId] = useState(practiceId)

  const onChange = (event) => {
    const value = event.target.value
    setSelectedId(value)
    setPracticeId(value)
  };

  const selectRef = useRef(null);

  useEffect(() => {
    const selectElement = selectRef.current;
    const choicesInstance = new Choices(selectElement, {
      searchEnabled: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    });

    return () => {
      choicesInstance.destroy();
    };
  }, []);

  return (
    <>
      <nav className="page-filter form">
        <div className="container is-md">
          <div className="form-item is-inline-md-up">
            <label className="a-form-label" htmlFor='js-choices-single-select'>プラクティスで絞り込む</label>
            <select
              className="a-form-select"
              onChange={onChange}
              ref={selectRef}
              value={selectedId}
              id='js-choices-single-select'
            >
              <option key="" value="">全ての日報を表示</option>
              {practices.map((practice) => {
                return (
                  <option key={practice.id} value={practice.id}>
                    {practice.title}
                  </option>
                )
              })}
            </select>
          </div>
        </div>
      </nav>
    </>
  )
}

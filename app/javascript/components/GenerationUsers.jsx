import React from 'react'
import useSWR from 'swr'
import User from './User.jsx'
import Pagination from './Pagination'
import usePage from './hooks/usePage'
import fetcher from '../fetcher'

export default function GenerationUsers({ generationID }) {
  const itemsPerPage = 24
  const { page, setPage } = usePage()
  const { data, error } = useSWR(
    `/api/generations/${generationID}.json?page=${page}&per=${itemsPerPage}`,
    fetcher
  )

  if (error) return <>An error has occurred.</>
  if (!data) return <>Loading...</>

  return (
    <div className="page-body">
      {data.totalPages > 1 && (
        <Pagination
          sum={data.totalPages * itemsPerPage}
          per={itemsPerPage}
          page={page}
          setPage={setPage}
        />
      )}
      <div className="container">
        <div className="users row">
          {data.users === null ? (
            <div className="empty">
              <i className="fa-solid fa-spinner fa-pulse" />
              ロード中
            </div>
          ) : data.users.length !== 0 ? (
            data.users.map((user) => (
              <User key={user.id} user={user} currentUser={data.currentUser} />
            ))
          ) : (
            <div className="row">
              <div className="a-empty-message">
                <div className="a-empty-message__icon">
                  <i className="fa-regular fa-smile"></i>
                </div>
                <p className="a-empty-message_text">
                  {generationID}期のユーザー一覧はありません
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
      {data.totalPages > 1 && (
        <Pagination
          sum={data.totalPages * itemsPerPage}
          per={itemsPerPage}
          page={page}
          setPage={setPage}
        />
      )}
    </div>
  )
}

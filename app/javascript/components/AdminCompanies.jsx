import React, { useState, useEffect } from 'react'
import queryString from 'query-string'
import useSWR from 'swr'
import fetcher from '../fetcher'
import Pagination from './Pagination'

export default function AdminCompanies() {
  const per = 20
  const neighbours = 4
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  useEffect(() => {
    setPage(page)
  }, [page])

  const { data, error } = useSWR(
    `/api/admin/companies.json?page=${page}&per=${per}`,
    fetcher
  )
  if (error) return <>An error has occurred.</>
  if (!data) return <>Loading...</>

  const handlePaginate = (p) => {
    setPage(p)
    window.history.pushState(null, null, `/admin/companies?page=${p}`)
  }

  return (
    <>
      {data.total_pages > 1 && (
        <Pagination
          sum={data.total_pages * per}
          per={per}
          neighbours={neighbours}
          page={page}
          onChange={(e) => handlePaginate(e.page)}
        />
      )}
      <div className="admin-table">
        <table className="admin-table__table">
          <thead className="admin-table__header">
            <tr className="admin-table__labels">
              <th className="admin-table__label">名前</th>
              <th className="admin-table__label">ロゴ</th>
              <th className="admin-table__label">ウェブサイト</th>
              <th className="admin-table__label">アドバイザー招待リンク</th>
              <th className="admin-table__label">研修生招待リンク</th>
              <th className="admin-table__label actions">編集</th>
            </tr>
          </thead>
          <tbody className="admin-table__items">
            {data.companies.map((company) => {
              return <AdminCompany key={company.id} company={company} />
            })}
          </tbody>
        </table>
      </div>
      {data.total_pages > 1 && (
        <Pagination
          sum={data.total_pages * per}
          per={per}
          neighbours={neighbours}
          page={page}
          onChange={(e) => handlePaginate(e.page)}
        />
      )}
    </>
  )
}

const AdminCompany = ({ company }) => {
  const url = `/companies/${company.id}`
  const editUrl = `/admin/companies/${company.id}/edit`

  return (
    <tr className="admin-table__item">
      <td className="admin-table__item-value">
        <a href={url}>{company.name}</a>
      </td>
      <td className="admin-table__item-value">
        <img className="admin-table__item-logo-image" src={company.logo_url} />
      </td>
      <td className="admin-table__item-value">{company.website}</td>
      <td className="admin-table__item-value is-text-align-center">
        <a
          title="アドバイザーサインアップURL"
          href={company.adviser_sign_up_url}
          className="a-button is-sm is-secondary is-icon">
          <i className="fa-solid fa-user-plus"></i>
        </a>
      </td>
      <td className="admin-table__item-value is-text-align-center">
        <a
          title="アドバイザーサインアップURL"
          href={company.trainee_sign_up_url}
          className="a-button is-sm is-secondary is-icon">
          <i className="fa-solid fa-user-plus"></i>
        </a>
      </td>
      <td className="admin-table__item-value is-text-align-center">
        <a
          title="アドバイザーサインアップURL"
          href={editUrl}
          className="a-button is-sm is-secondary is-icon">
          <i className="fa-solid fa-pen"></i>
        </a>
      </td>
    </tr>
  )
}

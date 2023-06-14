import React from 'react'
import Company from './Company'
import LoadingUsersPageCompaniesPlaceholder from './LoadingUsersPageCompaniesPlaceholder'
import useSWR from 'swr'
import fetcher from '../fetcher'

export default function Companies({ target }) {
  const { data, error } = useSWR(
    `/api/users/companies?target=${target}`,
    fetcher
  )

  if (error) return console.warn(error)
  if (!data) {
    return (
      <div className="page-body">
        <div className="container is-lg">
          <div className="card-list a-card is-loading">
            <LoadingUsersPageCompaniesPlaceholder />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="page-body">
      <div className="container is-lg">
        <div className="card-list a-card">
          {data.map((company) => (
            <Company key={company.id} company={company} />
          ))}
        </div>
      </div>
    </div>
  )
}

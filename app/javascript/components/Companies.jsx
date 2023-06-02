import React, { useState, useEffect } from 'react'
import CSRF from "../csrf";
import Company from './Company'
import LoadingUsersPageCompaniesPlaceholder from './LoadingUsersPageCompaniesPlaceholder'

export default function Companies({ target }) {
  const [companies, setCompanies] = useState([])
  const [loaded, setLoaded] = useState(false)

  useEffect(() => {
    getCompaniesPage()
  }, [])

  const getCompaniesPage = () => {
    const url = `/api/users/companies?target=${target}`

    fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => response.json())
      .then((companies) => {
        setCompanies(companies)
        setLoaded(true)
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className="page-body">
      <div className="container is-lg">
        {!loaded ? (
          <div className="card-list a-card is-loading">
            <LoadingUsersPageCompaniesPlaceholder />
          </div>
        ) : (
          <div className="card-list a-card">
            {companies.map((company) => (
              <Company key={company.id} company={company} />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

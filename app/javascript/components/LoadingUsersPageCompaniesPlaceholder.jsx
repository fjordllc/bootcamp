import React from 'react'
import LoadingUsersPageCompanyPlaceholder from './LoadingUsersPageCompanyPlaceholder'

export default function LoadingUsersPageCompaniesPlaceholder() {
  const companyCount = 9

  return (
    <div>
      {[...Array(companyCount)].map((_, index) => (
        <LoadingUsersPageCompanyPlaceholder key={index} />
      ))}
    </div>
  )
}

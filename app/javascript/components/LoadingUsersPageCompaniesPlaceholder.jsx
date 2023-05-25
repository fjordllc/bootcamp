import React from 'react';
import LoadingUsersPageCompanyPlaceholder from './LoadingUsersPageCompanyPlaceholder';

const LoadingUsersPageCompaniesPlaceholder = () => {
  const companyCount = 9;

  return (
    <div>
      {Array.from({ length: companyCount }).map((_, index) => (
        <LoadingUsersPageCompanyPlaceholder key={index} />
      ))}
    </div>
  );
};

export default LoadingUsersPageCompaniesPlaceholder;

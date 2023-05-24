import React, { useState, useEffect } from 'react';
import Company from './Company';
import LoadingUsersPageCompaniesPlaceholder from './LoadingUsersPageCompaniesPlaceholder';

const Companies = ({ target }) => {
  const [companies, setCompanies] = useState([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    getCompaniesPage();
  }, []);

  const token = () => {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  };

  const getCompaniesPage = () => {
    const url = `/api/users/companies?target=${target}`;

    fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token(),
      },
      credentials: 'same-origin',
      redirect: 'manual',
    })
      .then((response) => response.json())
      .then((json) => {
        setCompanies(json);
        setLoaded(true);
      })
      .catch((error) => {
        console.warn(error);
      });
  };

  return (
    <div className="page-body">
      <div className="container is-lg">
        {!loaded ? (
          <LoadingUsersPageCompaniesPlaceholder />
        ) : (
          <div className="card-list a-card">
            {companies.map((company) => (
              <Company key={company.id} company={company} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Companies;

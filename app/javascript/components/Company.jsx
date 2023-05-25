import React from 'react';

export default function Company({ company }){
  if (company.users.length === 0) {
    return null;
  }

  return (
    <div className="user-group">
      <header className="user-group__header">
        <h2 className="group-company-name">
          <a className="group-company-name__link" href={company.users_url}>
            <span className="group-company-name__icon">
              <img
                className="group-company-name__icon-image"
                title={company.name}
                alt={company.name}
                src={company.logo_url}
              />
            </span>
            <span className="group-company-name__name">
              <span className="group-company-name__label">{company.name}</span>
              <span className="group-company-name__label-option">{company.description}</span>
            </span>
          </a>
        </h2>
      </header>
      <div className="a-user-icons">
        <div className="a-user-icons__items">
          {company.users.map((user) => (
            <a className="a-user-icons__item-link" href={user.url} key={user.id}>
              <span className={`a-user-role is-${user.primary_role}`}>
                <img
                  src={user.avatar_url}
                  title={user.icon_title}
                  data-login-name={user.login_name}
                  className="a-user-icons__item-icon a-user-icon"
                />
              </span>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
};

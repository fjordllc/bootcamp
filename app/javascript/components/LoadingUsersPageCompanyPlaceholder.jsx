import React from 'react';
import LoadingUserIconPlaceholder from './LoadingUserIconPlaceholder';

export default function LoadingUsersPageCompanyPlaceholder(){
  const userIconCount = 16;

  return (
    <div className="user-group">
      <header className="user-group__header">
        <h2 className="group-company-name">
          <span className="group-company-name__link">
            <span className="group-company-name__icon">
              <span className="group-company-name__icon-image a-placeholder"></span>
            </span>
            <span className="group-company-name__name">
              <span className="group-company-name__label a-placeholder"></span>
              <span className="group-company-name__label-option a-placeholder"></span>
            </span>
          </span>
        </h2>
      </header>
      <div className="a-user-icons">
        <div className="a-user-icons__items">
          {[...Array(userIconCount)].map((_, index) => (
            <LoadingUserIconPlaceholder key={index} />
          ))}
        </div>
      </div>
    </div>
  );
};

import React, { useEffect, useRef } from 'react'
import userIcon from '../user-icon.js'

export default function Company({ company }) {
  if (company.users.length === 0) {
    return null
  }

  return (
    <div className="a-card user-group">
      <UserGroupHeader company={company} />
      <UserIcons users={company.users} />
    </div>
  )
}

function UserGroupHeader({ company }) {
  return (
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
            <span className="group-company-name__label-option">
              {company.description}
            </span>
          </span>
        </a>
      </h2>
    </header>
  )
}

function UserIcons({ users }) {
  // userIconの非React化により、useRef,useEffectを導入している。
  const userIconRef = useRef(null)
  useEffect(() => {
    const linkClass = 'a-user-icons__item-link'
    const imgClasses = ['a-user-icons__item-icon', 'a-user-icon']

    const userIconElements = users.map((user) => {
      return userIcon({
        user,
        linkClass,
        imgClasses,
        loginName: user.login_name
      })
    })

    if (userIconRef.current) {
      userIconRef.current.innerHTML = ''
      userIconElements.forEach((element) => {
        userIconRef.current.appendChild(element)
      })
    }
  }, [users])

  return (
    <div className="a-user-icons">
      <div className="a-user-icons__items" ref={userIconRef}></div>
    </div>
  )
}

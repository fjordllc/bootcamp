import React from 'react'
import clsx from 'clsx'

const UserGroup = ({ className, ...props }) => {
  return <div className={clsx('user-group', className)} {...props} />
}

const UserGroupHeader = ({ className, children, ...props }) => {
  return (
    <header className={clsx('user-group__header', className)} {...props}>
      <h2 className="user-group__title">{children}</h2>
    </header>
  )
}

const UserGroupIcons = ({ users, className, ...props }) => {
  return (
    <div className={clsx('a-user-icons', className)} {...props}>
      <div className="a-user-icons__items">
        {users.map((user) => (
          <UserIcon user={user} key={user.id} />
        ))}
      </div>
    </div>
  )
}

const UserIcon = ({ user }) => {
  const primaryRole = `is-${user.primary_role}`

  return (
    <a className="a-user-icons__item-link" href={user.url}>
      <span className={clsx('a-user-role', primaryRole)}>
        <img
          src={user.avatar_url}
          title={user.icon_title}
          data-login-name={user.login_name}
          className="a-user-icons__item-icon a-user-icon"
        />
      </span>
    </a>
  )
}

export { UserGroup, UserGroupHeader, UserGroupIcons }

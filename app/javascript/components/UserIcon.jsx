import React from 'react'

export default function UserIcon({ user, blockClassSuffix }) {
  return (
    <a href={user.url} className={`${blockClassSuffix}__user-link`}>
      <span className={`a-user-role is-${user.primary_role}`}>
        <img
          src={user.avatar_url}
          alt={user.icon_title}
          title={user.icon_title}
          className={`${blockClassSuffix}__user-icon a-user-icon`}
        />
      </span>
    </a>
  )
}

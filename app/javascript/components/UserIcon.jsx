import React from 'react'

export default function UserIcon({ user, blockClassSuffix }) {
  return (
    <a href={user.url} className={`${blockClassSuffix}__user-link`}>
    <img
      src={user.avatar_url}
      alt={user.icon_title}
      title={user.icon_title}
      className={`${blockClassSuffix}__user-icon a-user-icon is-${user.primary_role}`} />
    </a>
  )
}

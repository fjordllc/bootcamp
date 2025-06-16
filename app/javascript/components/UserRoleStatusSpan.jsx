import React from 'react'

export default function UserRoleStatusSpan({
  user,
  spanClassName,
  className,
  src,
  title,
  alt
}) {
  const roleClass = `is-${user.primary_role}`
  const joiningStatusClass = `is-${user.joining_status}`
  return (
    <span
      className={`a-user-role ${spanClassName} ${roleClass} ${joiningStatusClass}`}>
      <img className={className} src={src} title={title} alt={alt} />
    </span>
  )
}

export function getUserRoleStatusClass(user) {
  return `is-${user.primary_role} is-${user.joining_status}`
}

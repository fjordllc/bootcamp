import React from 'react'

export default function UserIconFrameClass({
  user,
  spanClassName,
  className,
  src,
  title,
  alt
}) {
  const roleClass = `is-${user.primary_role}`
  const joiningStatusClass =
    user.joining_status === 'new-user' ? 'is-new-user' : ''
  return (
    <span
      className={`a-user-role ${spanClassName} ${roleClass} ${joiningStatusClass}`}>
      <img className={className} src={src} title={title} alt={alt} />
    </span>
  )
}

export function getIconFrameClass(user) {
  return `is-${user.primary_role} is-${user.joining_status}`
}

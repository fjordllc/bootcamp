import React from 'react'

export default function CommentUserIcon({ comment }) {
  const roleClass = `is-${comment.primary_role}`
  const joiningStatusClass = `is-${comment.joining_status}`
  return (
    <a
      className="card-list-item__user-icons-icon"
      href={`/users/${comment.user_id}`}>
      <span className={`a-user-role ${roleClass} ${joiningStatusClass}`}>
        <img className="a-user-icon" src={comment.user_icon} />
      </span>
    </a>
  )
}

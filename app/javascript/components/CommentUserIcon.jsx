import React from 'react'

export default function CommentUserIcon({ comment, report }) {
  const roleClass = `is-${report.user.primary_role}`
  return (
    <a
      className="card-list-item__user-icons-icon"
      href={`/users/${comment.user_id}`}>
      <span className={`a-user-role ${roleClass}`}>
        <img className="a-user-icon" src={comment.user_icon} />
      </span>
    </a>
  )
}

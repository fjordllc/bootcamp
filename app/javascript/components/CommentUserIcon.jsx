import React from 'react'

export default function CommentUserIcon({comment}) {
  return (
    <a className="card-list-item__user-icons-icon" href={`/users/${comment.user_id}`}>
      <img className="a-user-icon" src={comment.user_icon} />
    </a>
  )
}

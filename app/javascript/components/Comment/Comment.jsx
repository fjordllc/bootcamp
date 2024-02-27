import React, { useState } from 'react'
import { CommentUserIcon, CommentThreadStart, CommentThreadEnd } from './Share'
import { CommentViewing } from './Viewing'
import { CommentEditing } from './Editing'
import clsx from 'clsx'

const CommentCompanyLink = ({ user }) => {
  if (!user.company || !user.adviser) return <></>
  return (
    <a className="thread-comment__company-link" href={user.url}>
      <img className="thread-comment__company-logo" src={user.logo_url} />
    </a>
  )
}

const Comment = ({
  comment,
  currentUser,
  isLatest,
  isValidating,
  availableEmojis,
  onDeleteComment,
  onUpdateComment,
  className,
  ...props
}) => {
  const [editing, setEditing] = useState(false)

  return (
    <div
      className={clsx('thread-comment', { 'is-latest': isLatest }, className)}
      {...props}
    >
      {/*
        id="latest-comment"は最新のコメントへのリンク先です
        アプリ内の複数箇所でリンク先として設定されています
      */}
      {isLatest && <div id='latest-comment' />}
      <CommentThreadStart>
        <a className="thread-comment__user-link" href={comment.user.url}>
          <CommentUserIcon user={comment.user} />
        </a>
        <CommentCompanyLink user={comment.user} />
      </CommentThreadStart>
      <CommentThreadEnd>
        {editing
          ? <CommentEditing
              comment={comment}
              isValidating={isValidating}
              onStopEditing={() => setEditing(false)}
              onUpdateComment={onUpdateComment}
            />
          : <CommentViewing
              comment={comment}
              currentUser={currentUser}
              availableEmojis={availableEmojis}
              onStartEditing={() => setEditing(true)}
              onDeleteComment={onDeleteComment}
            />}
      </CommentThreadEnd>
    </div>
  )
}

export {
  Comment,
}

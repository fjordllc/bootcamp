import React from 'react'
import clsx from 'clsx'

const CommentThreadStart = ({ children }) => {
  return <div className="thread-comment__start">{children}</div>
}

const CommentThreadEnd = ({ children }) => {
  return <div className="thread-comment__end">{children}</div>
}

// 画面幅が48em以上の場合のみ表示されるコンポーネント
// cssではなくてuseMediaQueryのようなものを使って
// react hooksで制御した方が分かり易いかもしれない
// https://github.com/yocontra/react-responsive
const CommentUserIcon = ({ user }) => {
  const roleClass = `is-${user.primary_role}`

  return (
    <span className={clsx('a-user-role', roleClass)}>
      <img
        className="thread-comment__user-icon a-user-icon"
        src={user.avatar_url}
        alt={user.icon_title}
        title={user.icon_title}
      />
    </span>
  )
}

const CommentTab = ({ isActive, setActiveTab }) => {
  return (
    <div className="a-form-tabs js-tabs">
      <div
        className={clsx('a-form-tabs__tab js-tabs__tab', {
          'is-active': isActive('comment')
        })}
        onClick={() => setActiveTab('comment')}>
        コメント
      </div>
      <div
        className={clsx('a-form-tabs__tab js-tabs__tab', {
          'is-active': isActive('preview')
        })}
        onClick={() => setActiveTab('preview')}>
        プレビュー
      </div>
    </div>
  )
}

export { CommentThreadStart, CommentThreadEnd, CommentUserIcon, CommentTab }

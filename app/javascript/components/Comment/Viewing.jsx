import React from 'react'
import MarkdownInitializer from '../../markdown-initializer'
// components
import Reactions from '../Reaction/Reactions'
import { TimeClipboard } from '../ui/TimeClipboard'
import * as Card from '../ui/Card'
import { Border } from '../ui/Border'
// utils
import clsx from 'clsx'

const Description = ({ comment }) => {
  const markdownDescription = new MarkdownInitializer().render(comment.description)

  return (
    <div className="thread-comment__description">
      {/* コメントしたユーザーがアドバイザーの場合、会社情報を表示 */}
      {comment.user.company && comment.user.adviser && (
        <a
          className="thread-comment__company-link is-hidden-md-up"
          href={comment.user.company.url}
        >
          <img
            className="thread-comment__company-logo"
            src={comment.user.company.logo_url}
          />
        </a>
      )}
      <div
        className="a-long-text is-md"
        dangerouslySetInnerHTML={{ __html: markdownDescription }}
      />
    </div>
  )
}

const CommentViewing = ({
  comment,
  currentUser,
  availableEmojis,
  getKey,
  onStartEditing,
  onDeleteComment
}) => {
  const commentURL = window.location.href.split('#')[0] + '#comment_' + comment.id
  const roleClass = `is-${comment.user.primary_role}`
  const isAdmin = currentUser.roles.includes("admin")

  return (
    <Card.Root>
      <Card.Header>
        {/* コメントしたユーザーと時間の情報 */}
        <h2 className="thread-comment__title">
          <a className='thread-comment__title-user-link is-hidden-md-up' href={comment.user.url}>
            <img className={clsx('thread-comment__title-user-icon a-user-icon', roleClass)} src={comment.user.avatar_url} title={comment.user.icon_title} />
          </a>
          <a className="thread-comment__title-link a-text-link" href={comment.user.url}>
            {comment.user.login_name}
          </a>
        </h2>
        {/*
          TODO 何故かidのurlへのリンクを開いてもリンク先へジャンプしてくれない
          Vueとはコンポー年とのマウントのさせかたが違うのが影響している？
         */}
        {/* コメントした時間の表示と日付のクリップボードへのコピー機能 */}
        <TimeClipboard
          className='thread-comment__created-at'
          url={commentURL}
          dateTime={comment.updated_at}
        />
      </Card.Header>
      <Border color='tint' />
      {/* コメントの表示 */}
      <Description comment={comment} />
      <Border color='tint' />
      {/* コメントへの絵文字でのリアクション */}
      <div className="thread-comment__reactions">
        <Reactions
          reactionable={comment}
          currentUser={currentUser}
          reactionableId={`Comment_${comment.id}`}
          availableEmojis={availableEmojis}
          getKey={getKey}
        />
      </div>
      <Border color='tint' />
      {/* コメントした本人か管理者だけに表示 */}
      {(comment.user.id === currentUser.id || isAdmin) && (
        <Card.Footer>
          {/* コメントの編集開始ボタン */}
          <Card.FooterItem>
            <button
              className="card-main-actions__action a-button is-secondary is-sm is-block"
              onClick={() => onStartEditing()}
            >
              <i className="fa-solid fa-pen" />
              編集
            </button>
          </Card.FooterItem>
          {/* コメントの削除ボタン */}
          <Card.FooterItem className='is-sub'>
            <button
              className="card-main-actions__muted-action"
              onClick={() => onDeleteComment()}
            >
              削除する
            </button>
          </Card.FooterItem>
        </Card.Footer>
      )}
    </Card.Root>
  )
}

export { CommentViewing }

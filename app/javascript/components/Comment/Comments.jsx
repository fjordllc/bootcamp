import React from 'react'
import { Comment } from './Comment'
import CommentForm from './CommentForm'
import CommentPlaceholder from './CommentPlaceholder'
import clsx from 'clsx'
import { useComment } from './useComment'
import { useCheck } from '../Check/useCheck'
import { useResponsibleMentor } from '../ResponsibleMentor/useResponsibleMentor'
import { useZustandStore } from '../../hooks/useZustandStore'

const CommentsHeader = ({ className, children, ...props }) => {
  return (
    <header className={clsx('thread-comments__header', className)} {...props}>
      <h2 className="thread-comments__title">{children}</h2>
    </header>
  )
}

const CommentsLoadMore = ({ onClick, loadMoreText }) => {
  return (
    <div className="thread-comments-more">
      <div className="thread-comments-more__inner">
        <div className="thread-comments-more__action">
          <button className="a-button is-lg is-text is-block" onClick={onClick}>
            {loadMoreText}
          </button>
        </div>
      </div>
    </div>
  )
}

const CommentsList = ({ className, children, ...props }) => {
  return (
    <div className={clsx('thread-comments__items', className)} {...props}>
      {children}
    </div>
  )
}

const Comments = ({
  title,
  commentableId,
  commentableType,
  currentUser,
  availableEmojis
}) => {
  const {
    data,
    error,
    isLoading,
    isValidating,
    isShowLoadMore,
    loadMoreText,
    getKey,
    handleLoadMore,
    handleCreateComment,
    handleUpdateComment,
    handleDeleteComment
  } = useComment({
    currentUserId: currentUser.id,
    commentableType,
    commentableId
  })
  const { isChecked, handleCreateCheck } = useCheck()
  const { handleBecomeResponsibleMentor, responsibleMentorState } =
    useResponsibleMentor()
  const { setWatchable } = useZustandStore((state) => state.watch)
  const isCheckable =
    currentUser.roles.includes('mentor') &&
    /^(Report|Product)$/.test(commentableType) &&
    !isChecked
  // 提出物のコメントで、メンターで、担当者がおらずに確認が済んでいない場合にtrue
  const isBecomeResponsibleMentor =
    commentableType === 'Product' &&
    isCheckable &&
    responsibleMentorState === 'absent' &&
    isChecked === false

  if (error) return <>エラーが発生しました。</>
  if (isLoading) return <CommentPlaceholder />

  return (
    <div id="comments" className="thread-comments loaded">
      {/*
        表示していないコメントを読み込むためのボタン
        現在は８件ごとにコメントを表示しており
        表示していないコメントが無いと消えます
      */}
      {isShowLoadMore && (
        <CommentsLoadMore
          onClick={() => handleLoadMore()}
          loadMoreText={loadMoreText}
        />
      )}
      {/* コメント欄のタイトル */}
      <CommentsHeader>{title}</CommentsHeader>
      {/* コメント一覧 */}
      <CommentsList>
        {data
          .reverse()
          .map(({ comments, comment_total_count: _commentTotalCount }) => {
            return comments.reverse().map((comment, index) => {
              return (
                <Comment
                  id={`comment_${comment.id}`}
                  key={comment.id}
                  comment={comment}
                  currentUser={currentUser}
                  isLatest={index === comments.length - 1}
                  isValidating={isValidating}
                  availableEmojis={
                    Array.isArray(availableEmojis)
                      ? availableEmojis
                      : JSON.parse(availableEmojis)
                  }
                  getKey={getKey}
                  onDeleteComment={() => {
                    if (window.confirm('削除してよろしいですか？')) {
                      handleDeleteComment(comment.id)
                    }
                  }}
                  onUpdateComment={handleUpdateComment}
                />
              )
            })
          })}
      </CommentsList>
      {/* コメント投稿フォーム */}
      <CommentForm
        currentUser={currentUser}
        isValidating={isValidating}
        isCheckable={isCheckable}
        isBecomeResponsibleMentor={isBecomeResponsibleMentor}
        isPreventCommentAndCheck={() => {
          const isConfirmed = () =>
            window.confirm('提出物を確認済にしてよろしいですか？')
          return commentableType === 'Product' && !isConfirmed()
        }}
        onCreateCommentAndWatch={async (description) => {
          await handleCreateComment(description)
          // Commentが作成されるとBackendでは自動でWatchも作成されるので、
          // フロントのZustandでも合わせてWatchする
          setWatchable({
            watchableId: commentableId,
            watchableType: commentableType
          })
        }}
        onCreateCheck={handleCreateCheck}
        onBecomeResponsibleMentor={() => {
          handleBecomeResponsibleMentor({ currentUserId: currentUser.id })
        }}
      />
    </div>
  )
}

export default Comments

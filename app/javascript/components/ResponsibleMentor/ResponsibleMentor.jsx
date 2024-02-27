import React from 'react'
import {
  useInitializeResponsibleMentor,
  useResponsibleMentor
} from './useResponsibleMentor'

// 注意
// ここでのcheckerは提出物の担当者を意味していて、確認したかどうかで使われているcheckableとは別の概念です
export default function ResponsibleMentor({
  responsibleUserId,
  responsibleUserName,
  responsibleUserAvatar,
  currentUserId,
  productId,
}) {
  useInitializeResponsibleMentor({
    initialResponsibleMentorId: responsibleUserId,
    productId,
    currentUserId
  })
  const {
    responsibleMentorState,
    handleBecomeResponsibleMentor,
    handleDeleteResponsibleMentor
  } = useResponsibleMentor()

  return (
    <>
      {/* 担当者が不在の場合 */}
      {responsibleMentorState === 'absent' && (
        <button
          className="a-button is-block is-sm is-secondary"
          onClick={() => handleBecomeResponsibleMentor()}>
          <i className="fas fa-hand-paper" />
          担当する
        </button>
      )}
      {/* 担当者が現在のユーザーの場合 */}
      {responsibleMentorState === 'currentUser' && (
        <button
          className="a-button is-block is-sm is-warning"
          onClick={() => handleDeleteResponsibleMentor()}>
          <i className="fas fa-times" />
          担当から外れる
        </button>
      )}
      {/* 現在のユーザー以外の担当者がいた場合 */}
      {responsibleMentorState === 'otherUser' && (
        <div className="a-button is-sm is-block card-list-item__assignee-button is-only-mentor">
          <span className="card-list-item__assignee-image">
            <img
              className="a-user-icon"
              src={responsibleUserAvatar}
              width="20"
              height="20"
              alt="Checker Avatar"
            />
          </span>
          <span className="card-list-item__assignee-name">{responsibleUserName}</span>
        </div>
      )}
    </>
  )
}

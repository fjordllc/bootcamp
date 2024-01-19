import React from 'react'
import { useProductChecker } from './useProductChecker'

// 注意
// ここでのcheckerは提出物の担当者を意味していて、確認したかどうかで使われているcheckableとは別の概念です
export default function ProductChecker({
  checkerId,
  checkerName,
  currentUserId,
  productId,
  checkerAvatar
}) {
  const {
    productChecker,
    onCreateProductChecker,
    onDeleteProductChecker
  } = useProductChecker(checkerId, productId, currentUserId)

  return (
    <>
      {/* 担当者が不在の場合 */}
      {productChecker === 'absent' && (
        <button
          className='a-button is-block is-sm is-secondary'
          onClick={onCreateProductChecker}>
          <i
            className='fas fa-hand-paper'
          />
          担当する
        </button>
      )}
      {/* 担当者が現在のユーザーの場合 */}
      {productChecker === 'currentUser' && (
        <button
          className='a-button is-block is-sm is-warning'
          onClick={onDeleteProductChecker}>
          <i
            className='fas fa-times'
          />
          担当から外れる
        </button>
      )}
      {/* 現在のユーザー以外の担当者がいた場合 */}
      {productChecker === 'otherUser' && (
        <div className="a-button is-sm is-block card-list-item__assignee-button is-only-mentor">
          <span className="card-list-item__assignee-image">
            <img
              className="a-user-icon"
              src={checkerAvatar}
              width="20"
              height="20"
              alt="Checker Avatar"
            />
          </span>
          <span className="card-list-item__assignee-name">{checkerName}</span>
        </div>
      )}
    </>
  )
}

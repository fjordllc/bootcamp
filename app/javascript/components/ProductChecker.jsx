import React, { useState } from 'react'
import CSRF from 'csrf'
import { checkProduct } from './Checkable.jsx'

export default function ProductChecker({
  checkerId,
  checkerName,
  currentUserId,
  productId,
  checkableType,
  checkerAvatar
}) {
  const [isCheckerExist, setisCheckerExist] = useState(checkerId)

  const buttonLabel = () => (isCheckerExist ? '担当から外れる' : '担当する')

  const checkInCharge = () => {
    checkProduct(
      productId,
      currentUserId,
      '/api/products/checker',
      isCheckerExist ? 'DELETE' : 'PATCH',
      CSRF.getToken()
    )
  }
  return (
    <>
      {(!checkerId || checkerId === currentUserId) && (
        <button
          className={`a-button is-block ${
            isCheckerExist ? 'is-warning' : 'is-secondary'
          } ${checkableType ? 'is-sm' : 'is-sm'} `}
          onClick={() => {
            setisCheckerExist(!isCheckerExist)
            checkInCharge()
          }}>
          <i
            className={`fas ${isCheckerExist ? 'fa-times' : 'fa-hand-paper'}`}
          />
          {buttonLabel()}
        </button>
      )}
      {checkerId && checkerId !== currentUserId && (
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

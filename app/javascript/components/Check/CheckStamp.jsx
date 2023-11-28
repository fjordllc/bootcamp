import React from 'react'
import { useCheck } from './useCheck'

const CheckStamp = ({ checkableId, checkableType }) => {
  const { checkId, createdAt, userName } = useCheck(checkableId, checkableType)

  return (
    <div className={checkId ? 'stamp stamp-approve' : ''}>
      {checkId && (
        <>
          <h2 className="stamp__content is-title">確認済</h2>
          <time className="stamp__content is-created-at">{createdAt}</time>
          <div className="stamp__content is-user-name">
            <div className="stamp__content-inner">{userName}</div>
          </div>
        </>
      )}
    </div>
  )
}

export default CheckStamp

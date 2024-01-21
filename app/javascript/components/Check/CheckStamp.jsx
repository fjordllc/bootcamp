import React from 'react'
import { useCheck } from './useCheck'

const CheckStamp = ({ checkableId, checkableType }) => {
  const { checkExists, createdAt, userName } = useCheck(
    checkableId,
    checkableType
  )

  return (
    checkExists && (
      <div className='stamp stamp-approve'>
        <h2 className="stamp__content is-title">確認済</h2>
        <time className="stamp__content is-created-at">{createdAt}</time>
        <div className="stamp__content is-user-name">
          <div className="stamp__content-inner">{userName}</div>
        </div>
      </div>
    )
  )
}

export default CheckStamp

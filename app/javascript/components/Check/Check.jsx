import React from 'react'
import ProductChecker from '../ProductChecker/ProductChecker'
import * as Card from '../ui/Card'
import { useCheck } from './useCheck'
import clsx from 'clsx'

const CheckComponent = ({
  emotion = null,
  checkableId,
  checkableType,
  checkableLabel,
  checkerId = null,
  checkerName = null,
  checkerAvatar = null,
  currentUserId = null
}) => {
  const { checkExists, onCreateCheck, onDeleteCheck } = useCheck(
    checkableId,
    checkableType
  )
  const buttonLabel = `${checkableLabel}${
    checkExists ? 'の確認を取り消す' : 'を確認'
  }`

  const handleToggleCheck = () => {
    if (checkExists) {
      onDeleteCheck()
    } else {
      const isSadEmotion = emotion === 'sad'
      // TODO querySelectorを辞めてpropsから渡したい
      const commentExists =
        parseInt(
          document.querySelector('a[href="#comments"] > span').innerHTML
        ) > 0
      const confirmMessage =
        '今日の気分は「sad」ですが、コメント無しで確認しますか？'
      const isConfirmed = () => window.confirm(confirmMessage)
      const isSadNoCommentNotComfirmed =
        isSadEmotion && !commentExists && !isConfirmed()
      if (isSadNoCommentNotComfirmed) return
      onCreateCheck()
    }
  }

  return (
    <Card.Footer className="is-only-mentor">
      {checkableType === 'Product' && (
        <Card.FooterItem>
          <ProductChecker
            checkerId={checkerId}
            checkerName={checkerName}
            currentUserId={currentUserId}
            productId={checkableId}
            checkableType={checkableType}
            checkerAvatar={checkerAvatar}
          />
        </Card.FooterItem>
      )}
      <Card.FooterItem className={clsx({ 'is-sub': checkExists })}>
        <button
          // shortcut.jsでhotkey(ctrl+b)の設定に使うid
          id="js-shortcut-check"
          className={clsx(
            'is-block',
            checkExists
              ? 'card-main-actions__muted-action'
              : 'a-button is-sm is-danger'
          )}
          onClick={handleToggleCheck}>
          {buttonLabel}
        </button>
      </Card.FooterItem>
    </Card.Footer>
  )
}

export default CheckComponent

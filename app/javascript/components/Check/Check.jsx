import React from 'react'
import ResponsibleMentor from '../ResponsibleMentor/SharedResponsibleMentor'
import * as Card from '../ui/Card'
import { useInitializeCheck, useCheck } from './useCheck'
import clsx from 'clsx'

const Check = ({
  emotion = null,
  checkableId,
  checkableType,
  checkableName,
  responsibleUserId = null,
  responsibleUserName = null,
  responsibleUserAvatar = null,
  currentUserId = null
}) => {
  useInitializeCheck(checkableId, checkableType)
  const { isChecked, handleCreateCheck, handleDeleteCheck } = useCheck()

  const handleCreateCheckClick = () => {
    const isSadEmotion = emotion === 'sad'
    // TODO querySelectorを辞めてpropsから渡したい
    const commentExists =
      parseInt(
        document.querySelector('a[href="#comments"] > span').innerHTML
      ) > 0
    const confirmMessage =
      '今日の気分は「sad」ですが、コメント無しで確認しますか？'
    // 変数定義時に実行させないため関数
    const isConfirmed = () => window.confirm(confirmMessage)
    const isSadNoCommentNotComfirmed =
      isSadEmotion && !commentExists && !isConfirmed()
    if (isSadNoCommentNotComfirmed) return
    handleCreateCheck()
  }

  return (
    <Card.Footer className="is-only-mentor">
      {/* 提出物のみで使う担当ボタン */}
      {checkableType === 'Product' && (
        // 確認されていた場合はCSSによって非表示
        <Card.FooterItem className={clsx({ hidden: isChecked })}>
          <ResponsibleMentor
            responsibleUserId={responsibleUserId}
            responsibleUserName={responsibleUserName}
            responsibleUserAvatar={responsibleUserAvatar}
            currentUserId={currentUserId}
            productId={checkableId}
          />
        </Card.FooterItem>
      )}
      {/* 確認or確認取り消しボタン */}
      <Card.FooterItem className={clsx({ 'is-sub': isChecked })}>
        {isChecked ? (
          <button
            // shortcut.jsでhotkey(ctrl+b)の設定に使うid
            id="js-shortcut-check"
            className='is-block card-main-actions__muted-action'
            onClick={handleDeleteCheck}>
            {`${checkableName}の確認を取り消す`}
          </button>
        ) : (
          <button
            // shortcut.jsでhotkey(ctrl+b)の設定に使うid
            id="js-shortcut-check"
            className='is-block a-button is-sm is-danger'
            onClick={handleCreateCheckClick}>
            {`${checkableName}を確認`}
          </button>
        )
        }
      </Card.FooterItem>
    </Card.Footer>
  )
}

export default Check

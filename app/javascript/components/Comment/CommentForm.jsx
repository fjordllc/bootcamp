import React, { useState, useRef } from 'react'
import {
  CommentThreadStart,
  CommentThreadEnd,
  CommentUserIcon,
  CommentTab
} from './Share'
import * as Markdown from '../Markdown'
import * as Card from '../ui/Card'
import toast from '../../toast'

/**
 * @typedef {Object} FormProps - コメントフォームのProps
 * @prop {any} currentUser - 現在のユーザー
 * @prop {bool} isValidating - コメントのリクエストの実行中かどうかの真偽値
 * @prop {bool} isCheckable - Commentableを確認済にしていいかどうかの真偽値
 * @prop {bool} isBecomeResponsibleMentor - 担当者になる必要があるかどうかの真偽値
 * @prop {() => bool} isPreventCommentAndCheck - 提出物を確認済にしていいかどうかの真偽値
 * @prop {(description: string) => Promise<void>} onCreateCommentAndWatch - コメントを作成してWatch状態にする際に呼ばれるイベントハンドラ
 * @prop {() => void} onCreateCheck - Commentableを確認済にする時に呼ばれるイベントハンドラ
 * @prop {() => bool} onBecomeResponsibleMentor - Commentableの担当者になる時に呼ばれるイベントハンドラ
ンドラ
 */

/**
 * Comment Form component
 * コメントフォームを表示するコンポーネント
 * @param {FormProps} formProps - コメントフォームのProps
 */
const CommentForm = ({
  currentUser,
  isValidating,
  isCheckable,
  isBecomeResponsibleMentor,
  isPreventCommentAndCheck,
  onCreateCommentAndWatch,
  onCreateCheck,
  onBecomeResponsibleMentor
}) => {
  const [description, setDescription] = useState('')
  const isValidDescrption = description.length > 0
  // 'comment' | 'preview'
  const [activeTab, setActiveTab] = useState('comment')
  const isActive = (tab) => tab === activeTab
  const textareaRef = useRef(null)
  const previewRef = useRef(null)
  const [isPosting, setIsPosting] = useState(false)

  const handleClickCreateComment = async () => {
    setIsPosting(true)
    try {
      // コメントの作成とWatchをして、担当者になる
      await onCreateCommentAndWatch(description)
      if (isBecomeResponsibleMentor) {
        await onBecomeResponsibleMentor()
        // TODO useResponsibleMentorの方のtoastが表示されます 分かりにくいかも
      } else {
        toast.methods.toast('コメントを投稿しました!')
      }
    } catch (error) {
      toast.methods.toast('コメントの投稿に失敗しました!', 'error')
    } finally {
      // クリーンアップ
      setDescription('')
      setActiveTab('comment')
      setIsPosting(false)
      previewRef.current.removePreviewLastChild()
      textareaRef.current.resizeToDefaultHeight()
    }
  }

  const handleClickCreateCommentAndCheck = async () => {
    if (isPreventCommentAndCheck()) return
    setIsPosting(true)
    try {
      // コメントの作成とWatchをして、確認OKにする
      await onCreateCommentAndWatch(description)
      await onCreateCheck()
      toast.methods.toast('コメントを投稿して確認OKにしました!')
    } catch (error) {
      toast.methods.toast('コメントの投稿に失敗しました!', 'error')
    } finally {
      // クリーンアップ
      setDescription('')
      setActiveTab('comment')
      setIsPosting(false)
      previewRef.current.removePreviewLastChild()
      textareaRef.current.resizeToDefaultHeight()
    }
  }

  return (
    <div className="thread-comment-form">
      {/* ログインユーザーのプロフィール画像 */}
      <CommentThreadStart>
        <CommentUserIcon user={currentUser} />
      </CommentThreadStart>
      {/* コメントフォーム本体 */}
      <CommentThreadEnd>
        <Card.Root className="thread-comment-form__form">
          {/* フォームのエディターモードとプレビューモードの切り替え */}
          <CommentTab isActive={isActive} setActiveTab={setActiveTab} />
          {/* Markdownエディターとプレビュー */}
          <Markdown.Root>
            <Markdown.Item isActive={isActive('comment')}>
              <Markdown.Form>
                <Markdown.Textarea
                  id="js-new-comment"
                  variant="warning"
                  data-preview="#new-comment-preview"
                  data-input=".new-comment-file-input"
                  name="new_comment[description]"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  ref={textareaRef}
                />
                <Markdown.File className="new-comment-file-input" />
              </Markdown.Form>
            </Markdown.Item>
            <Markdown.Item isActive={isActive('preview')}>
              <Markdown.Preview id="new-comment-preview" ref={previewRef} />
            </Markdown.Item>
          </Markdown.Root>
          <Card.Footer>
            {/* コメント送信ボタン */}
            <Card.FooterItem>
              <button
                id="js-shortcut-post-comment"
                className="a-button is-sm is-primary is-block"
                onClick={handleClickCreateComment}
                disabled={!isValidDescrption || isPosting || isValidating}>
                コメントする
              </button>
            </Card.FooterItem>
            {/* コメント・確認OK送信ボタン */}
            {isCheckable && (
              <Card.FooterItem>
                <button
                  className="a-button is-sm is-danger is-block"
                  onClick={handleClickCreateCommentAndCheck}
                  disabled={!isValidDescrption || isPosting || isValidating}>
                  <i className="fa-solid fa-check" /> 確認OKにする
                </button>
              </Card.FooterItem>
            )}
          </Card.Footer>
        </Card.Root>
      </CommentThreadEnd>
    </div>
  )
}

export default CommentForm

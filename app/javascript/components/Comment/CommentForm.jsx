import React, { useState, useRef } from 'react'
import {
  CommentThreadStart,
  CommentThreadEnd,
  CommentUserIcon,
  CommentTab,
} from './Share'
import * as Markdown from '../Markdown'
import * as Card from '../ui/Card'
import { useTextarea } from './useTextarea'
import toast from '../../toast'

/* コメントフォーム */
const CommentForm = ({
  onCreateCommentAndWatch,
  onCreateCheck,
  onBecomeResponsibleMentor,
  isCheckable,
  isPreventCommentAndCheck,
  currentUser,
}) => {
  const [description, setDescription] = useState('')
  const isValidDescrption = description.length > 0
  // 'comment' | 'preview'
  const [activeTab, setActiveTab] = useState('comment')
  const isActive = (tab) => tab === activeTab
  const textareaRef = useRef(null)
  const previewRef = useRef(null)
  useTextarea(textareaRef)
  const [isPosting, setIsPosting] = useState(false)

  // Markdownのプレビュー要素の削除
  const removePreviewLastChild = () => {
    while (previewRef.current.lastChild) {
      previewRef.current.removeChild(previewRef.current.lastChild)
    }
  }

  const handleClickCreateComment = () => {
    setIsPosting(true)
    try {
      // コメントの作成とWatchをして、担当者になる
      onCreateCommentAndWatch(description)
      onBecomeResponsibleMentor()
      toast.methods.toast('コメントを投稿して担当者になりました')
    } catch (error) {
      toast.methods.toast('コメントの投稿に失敗しました', 'error')
    } finally {
      // クリーンアップ
      setDescription('')
      removePreviewLastChild()
      setActiveTab('comment')
      setIsPosting(false)
      // this.resizeTextarea()
    }
  }

  const handleClickCreateCommentAndCheck = () => {
    if (isPreventCommentAndCheck()) return
    setIsPosting(true)
    try {
      // コメントの作成とWatchをして、確認OKにする
      onCreateCommentAndWatch(description)
      onCreateCheck()
      toast.methods.toast('コメントを投稿して確認OKにしました')
    } catch (error) {
      toast.methods.toast('コメントの投稿に失敗しました', 'error')
    } finally {
      // クリーンアップ
      setDescription('')
      removePreviewLastChild()
      setActiveTab('comment')
      setIsPosting(false)
      // this.resizeTextarea()
    }
  }

  return (
    <div className="thread-comment-form">
      {/* ログインユーザーのプロフィール画像 */}
      <CommentThreadStart>
        <CommentUserIcon
          user={currentUser}
        />
      </CommentThreadStart>
      {/* コメントフォーム本体 */}
      <CommentThreadEnd>
        <Card.Root className='thread-comment-form__form'>
          {/* フォームのエディターモードとプレビューモードの切り替え */}
          <CommentTab isActive={isActive} setActiveTab={setActiveTab}/>
          {/* Markdownエディターとプレビュー */}
          <Markdown.Root>
            <Markdown.Item isActive={isActive('comment')}>
              <Markdown.Form>
                <Markdown.Textarea
                  id='js-new-comment'
                  variant='warning'
                  data-preview='#new-comment-preview'
                  data-input='#new-comment-file-input'
                  name='new_comment[description]'
                  description={description}
                  setDescription={setDescription}
                  ref={textareaRef}
                />
                <Markdown.File id='new-comment-file-input' />
              </Markdown.Form>
            </Markdown.Item>
            <Markdown.Item isActive={isActive('preview')}>
              <Markdown.Preview id='new-comment-preview' ref={previewRef} />
            </Markdown.Item>
          </Markdown.Root>
          <Card.Footer>
            {/* コメント送信ボタン */}
            <Card.FooterItem>
              <button
                id='js-shortcut-post-comment'
                className='a-button is-sm is-primary is-block'
                onClick={handleClickCreateComment}
                disabled={!isValidDescrption || isPosting}
              >
                コメントする
              </button>
            </Card.FooterItem>
            {/* コメント・確認OK送信ボタン */}
            {isCheckable &&
              <Card.FooterItem>
                <button
                  className='a-button is-sm is-danger is-block'
                  onClick={handleClickCreateCommentAndCheck}
                  disabled={!isValidDescrption || isPosting}
                >
                  <i className="fa-solid fa-check" /> 確認OKにする
                </button>
              </Card.FooterItem>
            }
          </Card.Footer>
        </Card.Root>
      </CommentThreadEnd>
    </div>
  )
}

export default CommentForm

import React, { useState, useRef } from 'react'
import 'dayjs/locale/ja'
import { CommentTab } from './Share'
import * as Card from '../ui/Card'
import { Border } from '../ui/Border'
import * as Markdown from '../Markdown'
import { useTextarea } from '../Markdown/useTextarea'

const CommentEditing = ({
  comment,
  isValidating,
  onStopEditing,
  onUpdateComment
}) => {
  // 'comment' | 'preview'
  const [activeTab, setActiveTab] = useState('comment')
  const [description, setDescription] = useState(comment.description)
  const isActive = (tab) => tab === activeTab
  const textareaRef = useRef(null)
  useTextarea(`#js-comment-${comment.id}`)

  return (
    <Card.Root>
      <div className="thread-comment-form__form">
        <CommentTab isActive={isActive} setActiveTab={setActiveTab} />
        <Markdown.Root>
          <Markdown.Item isActive={isActive('comment')}>
            <Markdown.Form>
              <Markdown.Textarea
                id={`js-comment-${comment.id}`}
                data-preview={`#js-comment-preview-${comment.id}`}
                data-input={`#js-comment-file-input-${comment.id}`}
                name="comment[description]"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                ref={textareaRef}
              />
              <Markdown.File id={`js-comment-file-input-${comment.id}`} />
            </Markdown.Form>
          </Markdown.Item>
          <Markdown.Item isActive={isActive('preview')}>
            <Markdown.Preview id={`js-comment-preview-${comment.id}`} />
          </Markdown.Item>
        </Markdown.Root>
        <Border color="tint" />
        <Card.Footer>
          <Card.FooterItem>
            <button
              className="a-button is-sm is-primary is-block"
              onClick={() => {
                onUpdateComment(comment.id, description)
                onStopEditing()
              }}
              disabled={isValidating}>
              保存する
            </button>
          </Card.FooterItem>
          <Card.FooterItem>
            <button
              className="a-button is-sm is-secondary is-block"
              onClick={() => onStopEditing()}
              disabled={isValidating}>
              キャンセル
            </button>
          </Card.FooterItem>
        </Card.Footer>
      </div>
    </Card.Root>
  )
}

export { CommentEditing }

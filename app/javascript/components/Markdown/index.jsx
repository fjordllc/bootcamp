import React, { useRef, forwardRef, useImperativeHandle } from 'react'
import { useTextarea } from './useTextarea'
import clsx from 'clsx'

const Markdown = ({
  children,
}) => {
  return (
    <div className='a-markdown-input js-markdown-parent'>
      {children}
    </div>
  )
}

Markdown.displayName = 'Markdown'

const MarkdownItem = ({
  isActive,
  children,
}) => {
  return (
    <div className={clsx('a-markdown-input__inner js-tabs__content', { 'is-active': isActive })}>
      {children}
    </div>
  )
}

MarkdownItem.displayName = 'MarkdownItem'

const MarkdownForm = ({ children }) => {
  return (
    <div className="form-textarea">
      {children}
    </div>
  )
}

MarkdownForm.displayName = 'MarkdownForm'

const MarkdownTextarea = forwardRef(({
  variant = 'primary',
  id,
  className,
  value = '',
  onChange,
  ...props
}, ref) => {
  const { isEditing, teatareaRef } = useTextarea({ selector: `#${id}`, value, ref })
  if (isEditing) props['data-editing'] = true

  return (
    <div className="form-textarea__body">
      <textarea
        id={id}
        className={clsx('a-text-input a-markdown-input__textarea', variant === 'warning' ? 'js-warning-form' : 'primary', className)}
        value={value}
        onChange={onChange}
        ref={teatareaRef}
        {...props}
      />
    </div>
  )
})

MarkdownTextarea.displayName = 'MarkdownTextarea'

const MarkdownFile = ({ ...props }) => {
  return (
    <div className="form-textarea__footer">
      <div className="form-textarea__insert">
        <label className="a-file-insert a-button is-xs is-text-reversal is-block">
          ファイルを挿入
          <input
            type="file"
            multiple
            {...props}
          />
        </label>
      </div>
    </div>
  )
}

MarkdownFile.displayName = 'MarkdownFile'

const MarkdownPreview = forwardRef(({ ...props }, ref) => {
  const previewRef = useRef(null)

  useImperativeHandle(ref, () => {
    return {
      /**
       * Markdownのプレビュー要素の削除
       */
      removePreviewLastChild() {
        while (previewRef.current.lastChild) {
          previewRef.current.removeChild(previewRef.current.lastChild)
        }
      }
    }
  })

  return (
    <div
      className="a-long-text is-md a-markdown-input__preview"
      ref={previewRef}
      {...props}
    />
  )
})

MarkdownPreview.displayName = 'MarkdownPreview'

const Root = Markdown
const Item = MarkdownItem
const Form = MarkdownForm
const Textarea = MarkdownTextarea
const File = MarkdownFile
const Preview = MarkdownPreview

export { Root, Item, Form, Textarea, File, Preview }

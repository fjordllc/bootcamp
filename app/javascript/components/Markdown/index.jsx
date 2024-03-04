import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react'
import { useBeforeunload } from '../../hooks/useBeforeunload'
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
  className,
  description,
  setDescription,
  ...props
}, ref) => {
  const teatareaRef = useRef(null)
  const [defaultTextareaSize, setDefaultTextareaSize] = useState(158)

  useEffect(() => {
    setDefaultTextareaSize(teatareaRef.current?.scrollHeight)
  }, [])

  const { onPageHasUnsavedChanges, onAllChangesSaved } = useBeforeunload()

  useEffect(() => {
    if (description.length > 0) {
      onPageHasUnsavedChanges()
    }
    return () => onAllChangesSaved()
  }, [description])

  useImperativeHandle(ref, () => {
    return {
      resizeToDefaultHeight() {
        teatareaRef.current.style.height = `${defaultTextareaSize}px`
      }
    }
  })

  return (
    <div className="form-textarea__body">
      <textarea
        className={clsx('a-text-input a-markdown-input__textarea', variant === 'warning' ? 'js-warning-form' : 'primary', className)}
        value={description}
        onChange={(e) => setDescription(e.target.value)}
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
  return (
    <div
      className="a-long-text is-md a-markdown-input__preview"
      ref={ref}
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

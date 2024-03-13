import { useState, useRef, useEffect, useImperativeHandle } from 'react'
import { useBeforeunload } from '../../hooks/useBeforeunload'
import TextareaInitializer from '../../textarea-initializer'

export const useTextarea = ({ selector, value = '', ref }) => {
  const teatareaRef = useRef(null)
  const [defaultTextareaSize, setDefaultTextareaSize] = useState(158)
  const isEditing = value.length > 0

  useEffect(() => {
    setDefaultTextareaSize(teatareaRef.current?.scrollHeight)
  }, [])

  const { onPageHasUnsavedChanges, onAllChangesSaved } = useBeforeunload()

  useEffect(() => {
    if (isEditing) {
      onPageHasUnsavedChanges()
    }
    return () => onAllChangesSaved()
  }, [value])

  useImperativeHandle(ref, () => {
    return {
      resizeToDefaultHeight() {
        teatareaRef.current.style.height = `${defaultTextareaSize}px`
      },
      onAllChangesSaved
    }
  })

  useEffect(() => {
    TextareaInitializer.initialize(selector)
  }, [])

  return { isEditing, teatareaRef }
}

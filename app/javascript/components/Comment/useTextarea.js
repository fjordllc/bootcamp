import { useEffect } from 'react'
import TextareaInitializer from '../../textarea-initializer-copy'

/**
 * propTypes.node
*/
export const useTextarea = (elementRef) => {
  // const defaultTextareaSize = element.current.scrollHeight

  useEffect(() => {
    TextareaInitializer.initialize(elementRef.current)
  }, [])

  const resizeTextarea = () => {
    // element.current.style.height = `${defaultTextareaSize}px`
  }
  return { resizeTextarea }
}

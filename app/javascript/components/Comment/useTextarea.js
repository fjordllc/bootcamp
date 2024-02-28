import { useEffect } from 'react'
import TextareaInitializer from '../../textarea-initializer-element'

export const useTextarea = (elementRef) => {
  useEffect(() => {
    TextareaInitializer.initialize(elementRef.current)
  }, [])

  // const resizeTextarea = () => {
  //   // element.current.style.height = `${defaultTextareaSize}px`
  // }
  // return { resizeTextarea }
}

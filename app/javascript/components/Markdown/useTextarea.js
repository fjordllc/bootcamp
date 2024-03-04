import { useEffect } from 'react'
import TextareaInitializer from '../../textarea-initializer'

export const useTextarea = (selector) => {
  useEffect(() => {
    TextareaInitializer.initialize(selector)
  }, [])
}

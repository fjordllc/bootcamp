import { useReducer } from 'react'
import toast from '../../toast'
import { productCheckerApi } from './productCheckerApi'

const reducer = (_state, action) => {
  switch (action) {
    case 'becomeProductChecker':
      return 'currentUser'
    case 'deleteProductChecker':
      return 'absent'
    default:
      throw new Error('Unknown action: ' + action.type)
  }
}

const createInitialState = ({ checkerId, currentUserId }) => {
  if (!checkerId) {
    return 'absent'
  } else if (checkerId === currentUserId) {
    return 'currentUser'
  } else {
    return 'otherUser'
  }
}

export const useProductChecker = (checkerId, productId, currentUserId) => {
  const [productChecker, dispatch] = useReducer(
    reducer,
    { checkerId, currentUserId },
    createInitialState
  )

  const { createProductChecker, deleteProductChecker } = productCheckerApi(
    productId,
    currentUserId
  )

  const onCreateProductChecker = () => {
    createProductChecker()
      .then(() => {
        dispatch('becomeProductChecker')
        toast.methods.toast('担当になりました。')
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast('担当になるのに失敗しました。', 'error')
      })
  }

  const onDeleteProductChecker = () => {
    deleteProductChecker()
      .then(() => {
        dispatch('deleteProductChecker')
        toast.methods.toast('担当から外れました。')
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast('担当から外れるのに失敗しました。', 'error')
      })
  }

  return {
    productChecker,
    onCreateProductChecker,
    onDeleteProductChecker
  }
}

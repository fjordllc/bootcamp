import { useReducer, useCallback } from 'react'
import toast from '../../toast'
import {
  createResponsibleMentor,
  deleteResponsibleMentor
} from './responsibleMentorApi'

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

const createInitialState = ({ responsibleMentorId, currentUserId }) => {
  if (!responsibleMentorId) {
    return 'absent'
  } else if (responsibleMentorId === currentUserId) {
    return 'currentUser'
  } else {
    return 'otherUser'
  }
}

export const useResponsibleMentor = ({
  responsibleMentorId,
  productId,
  currentUserId
}) => {
  const [responsibleMentorState, dispatch] = useReducer(
    reducer,
    { responsibleMentorId, currentUserId },
    createInitialState
  )

  const handleBecomeResponsibleMentor = useCallback(
    ({ currentUserId }) => {
      createResponsibleMentor({ productId, currentUserId })
        .then(() => {
          dispatch('becomeProductChecker')
          toast.methods.toast('担当になりました。')
        })
        .catch((error) => {
          console.error(error)
          toast.methods.toast('担当になるのに失敗しました。', 'error')
        })
    },
    [productId]
  )

  const handleDeleteResponsibleMentor = useCallback(() => {
    deleteResponsibleMentor({ productId })
      .then(() => {
        dispatch('deleteProductChecker')
        toast.methods.toast('担当から外れました。')
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast('担当から外れるのに失敗しました。', 'error')
      })
  }, [])

  return {
    responsibleMentorState,
    handleBecomeResponsibleMentor,
    handleDeleteResponsibleMentor
  }
}

import { useEffect, useCallback } from 'react'
import { useShallow } from 'zustand/react/shallow'
import { useZustandStore } from '../../hooks/useZustandStore'
import toast from '../../toast'
import {
  createResponsibleMentor,
  deleteResponsibleMentor
} from './responsibleMentorApi'

// 同じページ内の1箇所でのみ呼ぶこと
export const useInitializeResponsibleMentor = ({
  initialResponsibleMentorId,
  productId,
  currentUserId
}) => {
  const { setInitialResponsibleMentorState } = useZustandStore(
    useShallow((state) => state.responsibleMentor)
  )

  // productIdとresponsibleMentorStateの初期化を行います
  // もし使えるならcontextを使って初期化した方が良い
  // https://docs.pmnd.rs/zustand/guides/initialize-state-with-props
  useEffect(() => {
    setInitialResponsibleMentorState({
      productId,
      responsibleMentorId: initialResponsibleMentorId,
      currentUserId
    })
  }, [])
}

// useInitializeResponsibleMentorを読んだ後なら同じページ内の複数箇所で使えてデータは同期されます
export const useResponsibleMentor = () => {
  const {
    productId,
    responsibleMentorState,
    becomeResponsibleMentor,
    absentResponsibleMentor
  } = useZustandStore(useShallow((state) => state.responsibleMentor))

  const handleBecomeResponsibleMentor = useCallback(
    ({ currentUserId }) => {
      createResponsibleMentor({ productId, currentUserId })
        .then(() => {
          becomeResponsibleMentor()
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
        absentResponsibleMentor()
        toast.methods.toast('担当から外れました。')
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast('担当から外れるのに失敗しました。', 'error')
      })
  }, [productId])

  return {
    responsibleMentorState,
    handleBecomeResponsibleMentor,
    handleDeleteResponsibleMentor
  }
}

import { useEffect, useCallback } from 'react'
import toast from '../../toast'
import { useZustandStore } from '../../hooks/useZustandStore.js'
import { useShallow } from 'zustand/react/shallow'
import { createCheck, deleteCheck } from './checkApi'

// 同じページ内の1箇所でのみ呼ぶこと
export const useInitializeCheck = (checkableId, checkableType) => {
  const { setCheckable } = useZustandStore(
    useShallow((state) => state.checkable)
  )
  // Apiからcheckableの値を受け取るための初期化
  // もし使えるならcontextを使って初期化した方が良い
  // https://docs.pmnd.rs/zustand/guides/initialize-state-with-props
  useEffect(() => {
    setCheckable({ checkableId, checkableType })
  }, [])
}

// useInitializeCheckを読んだ後なら同じページ内の複数箇所で使えてデータは同期されます
export const useCheck = () => {
  const {
    checkId,
    isChecked,
    createdAt,
    checkerUserName,
    checkableId,
    checkableType,
    setCheckable
  } = useZustandStore(useShallow((state) => state.checkable))

  const handleCreateCheck = useCallback(() => {
    createCheck(checkableId, checkableType)
      .then(() => {
        setCheckable({ checkableId, checkableType })
        const message = {
          Product: '提出物を確認済みにしました。',
          Report: '日報を確認済みにしました。'
        }
        toast.methods.toast(message[checkableType])
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast(error.message, 'error')
      })
  }, [checkableId, checkableType])

  const handleDeleteCheck = useCallback(() => {
    deleteCheck(checkId, checkableId, checkableType)
      .then(() => {
        setCheckable({ checkableId, checkableType })
        const message = {
          Product: '提出物の確認を取り消しました。',
          Report: '日報の確認を取り消しました。'
        }
        toast.methods.toast(message[checkableType])
      })
      .catch((error) => {
        console.error(error)
        toast.methods.toast(error.message, 'error')
      })
  }, [checkId, checkableId, checkableType])

  return {
    isChecked,
    createdAt,
    checkerUserName,
    handleCreateCheck,
    handleDeleteCheck
  }
}

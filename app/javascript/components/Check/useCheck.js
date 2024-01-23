import { useEffect } from 'react'
import toast from '../../toast'
import { useZustandStore } from '../../hooks/useZustandStore.js'
import { useShallow } from 'zustand/react/shallow'
import { checkClient } from './checkApi'

export const useCheck = (checkableId, checkableType) => {
  const [{ checkId, createdAt, userName }, setCheckable] = useZustandStore(
    useShallow((state) => [state.checkable, state.setCheckable])
  )

  const { createCheck, deleteCheck } = checkClient(
    checkId,
    checkableId,
    checkableType
  )

  const checkExists = !!checkId

  const onCreateCheck = () => {
    createCheck()
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
  }

  const onDeleteCheck = () => {
    deleteCheck()
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
  }

  // Apiからcheckableの値を受け取るための初期化
  // もし使えるならcontextを使って初期化した方が良い
  // https://docs.pmnd.rs/zustand/guides/initialize-state-with-props
  useEffect(() => {
    setCheckable({ checkableId, checkableType })
  }, [checkableId, checkableType])

  return {
    checkExists,
    createdAt,
    userName,
    onCreateCheck,
    onDeleteCheck
  }
}

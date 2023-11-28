import { useEffect } from 'react'
import toast from '../../toast'
import { useZustandStore } from '../../hooks/useZustandStore.js'
import { createCheck, deleteCheck } from './checkApi'

export const useCheck = (checkableId, checkableType) => {
  const [{ checkId, createdAt, userName }, setCheckable] = useZustandStore((state) => [
    state.checkable,
    state.setCheckable
  ])

  const onCreateCheck = () => {
    createCheck(checkableId, checkableType).then(() => {
      setCheckable({ checkableId, checkableType })
      const message = {
        'Product': '提出物を確認済みにしました。',
        'Report': '日報を確認済みにしました。'
      }
      toast.methods.toast(message[checkableType])
    }).catch((error) => {
      console.error(error)
      toast.methods.toast(error.message, 'error')
    })
  }

  const onDeleteCheck = () => {
    deleteCheck(checkId, checkableId, checkableType).then(() => {
      setCheckable({ checkableId, checkableType })
      const message = {
        'Product': '提出物の確認を取り消しました。',
        'Report': '日報の確認を取り消しました。'
      }
      toast.methods.toast(message[checkableType])
    }).catch((error) => {
      console.error(error)
      toast.methods.toast(error.message, 'error')
    })
  }

  // ApiからwatchIdの値を受け取るための初期化
  // もし使えるならcontextを使って初期化した方が良い
  // https://docs.pmnd.rs/zustand/guides/initialize-state-with-props
  useEffect(() => {
    setCheckable({ checkableId, checkableType })
  }, [checkableId, checkableType])

  return {
    checkId,
    createdAt,
    userName,
    onCreateCheck,
    onDeleteCheck
  }
}

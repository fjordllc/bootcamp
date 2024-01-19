import { useEffect } from 'react'
import toast from '../../toast'
import { useZustandStore } from '../../hooks/useZustandStore'
import { useShallow } from 'zustand/react/shallow'
import { createWatch, deleteWatch } from './watchApi'

export const useWatch = (watchableId, watchableType) => {
  const [watchId, setWatchable] = useZustandStore(
    useShallow((state) => [state.watchId, state.setWatchable])
  )

  const watchExists = !!watchId

  const handleCreateWatch = () => {
    createWatch(watchableType, watchableId).
      then((watch) => {
        if (watch.message) {
          toast.methods.toast(watch.message, 'error');
        } else {
          toast.methods.toast('Watchしました！');
          setWatchable({
            watchableId: watch.watchable_id,
            watchableType: watch.watchable_type,
          })
        }
      })
      .catch((error) => {
        toast.methods.toast('Watchするのに失敗しました', 'error')
        console.error(error)
      })
  }

  const handleDeleteWatch = async () => {
    deleteWatch(watchId)
      .then(() => {
        toast.methods.toast('Watchを外しました')
        setWatchable({
          watchableId: watchableId,
          watchableType: watchableType,
        })
        // 元のvueのコードではここで下記のイベントを発行していたので
        // 移行する時に注意 移行後にこのコメントは消去
        // this.$emit('update-index')
      })
      .catch((error) => {
        toast.methods.toast('Watchを外すのに失敗しました', 'error')
        console.error(error)
      })
  }

  // ApiからwatchIdの値を受け取るための初期化
  // もし使えるならcontextを使って初期化した方が良い
  // https://docs.pmnd.rs/zustand/guides/initialize-state-with-props
  useEffect(() => {
    setWatchable({
      watchableId: watchableId,
      watchableType: watchableType
    })
  }, [watchableId, watchableType])

  return {
    watchExists,
    handleCreateWatch,
    handleDeleteWatch,
  }
}

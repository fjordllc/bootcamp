import { useSWRConfig } from 'swr'
// eslint-disable-next-line camelcase
import { unstable_serialize } from 'swr/infinite'
import { createReaction, deleteReaction } from './reactionApi'
import toast from '../../toast'

export const useReaction = (getKey, reactionableId) => {
  const { mutate } = useSWRConfig()
  const handleCreateReaction = (kind) => {
    // https://swr.vercel.app/ja/docs/pagination#global-mutate-with-useswrinfinite
    mutate(unstable_serialize(getKey), (_prevComments) => {
      createReaction(reactionableId, kind).catch((error) => {
        console.error(error)
        toast.methods.toast(
          'コメントにリアクションを追加出来ませんでした',
          'error'
        )
      })
    })
  }
  const handleDeleteReaction = (id) => {
    mutate(unstable_serialize(getKey), (_prevComments) => {
      deleteReaction(id).catch((error) => {
        console.error(error)
        toast.methods.toast(
          'コメントのリアクションを削除出来ませんでした',
          'error'
        )
      })
    })
  }

  return { handleCreateReaction, handleDeleteReaction }
}

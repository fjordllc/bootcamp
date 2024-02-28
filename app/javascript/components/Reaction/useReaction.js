import { useSWRConfig } from 'swr'
// eslint-disable-next-line camelcase
import { unstable_serialize } from "swr/infinite"
import { createReaction, deleteReaction } from './reactionApi'

export const useReaction = (getKey, reactionableId) => {
  const { mutate } = useSWRConfig()
  const handleCreateReaction = (kind) => {
    // https://swr.vercel.app/ja/docs/pagination#global-mutate-with-useswrinfinite
    mutate(unstable_serialize(getKey), (prevReactionable) => {
      console.log(prevReactionable)
      createReaction(reactionableId, kind)
        .then((reaction) => {
          console.log(reaction)
        })
    })
  }
  const handleDeleteReaction = (id) => {
    mutate(unstable_serialize(getKey), (prevReactionable) => {
      console.log(prevReactionable)
      deleteReaction(id)
    })
  }

  return {handleCreateReaction, handleDeleteReaction}
}

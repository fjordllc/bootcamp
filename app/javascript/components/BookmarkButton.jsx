import React from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import Bootcamp from '../bootcamp'
import toast from '../toast'

export default function BookmarkButton({ bookmarkableId, bookmarkableType }) {
  const bookmarkUrl = `/api/bookmarks.json?bookmarkable_type=${bookmarkableType}&bookmarkable_id=${bookmarkableId}`
  const { data, error, isLoading, isValidating, mutate } = useSWR(
    bookmarkUrl,
    fetcher
  )
  const isBookmarked = data?.bookmarks?.length > 0

  // もしapiから返されるデータが更新しやすいものなら
  // mutateではOptimistic Updatesを使った方が良いです
  // https://swr.vercel.app/ja/docs/mutation#optimistic-updates
  const bookmark = () => {
    Bootcamp.post(bookmarkUrl)
      .then(() => {
        toast.methods.toast('Bookmarkしました！')
        mutate()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  const unbookmark = () => {
    Bootcamp.delete(`/api/bookmarks/${data.bookmarks[0].id}`)
      .then(() => {
        toast.methods.toast('Bookmarkを削除しました')
        mutate()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  if (error) console.error(error)

  return isBookmarked ? (
    <button
      id="bookmark-button"
      disabled={isLoading || isValidating}
      className="a-bookmark-button a-button is-sm is-block is-active is-main"
      onClick={() => unbookmark()}>
      Bookmark中
    </button>
  ) : (
    <button
      id="bookmark-button"
      disabled={isLoading || isValidating}
      className="a-bookmark-button a-button is-sm is-block is-inactive is-muted"
      onClick={() => bookmark()}>
      Bookmark
    </button>
  )
}

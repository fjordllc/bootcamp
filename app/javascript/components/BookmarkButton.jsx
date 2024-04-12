import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import Bootcamp from '../bootcamp'
import toast from '../toast'

export default function BookmarkButton({ bookmarkableId, bookmarkableType }) {
  const [isBookmark, setIsBookmark] = useState('')
  let bookmarkId = null
  const bookmarkUrl = `/api/bookmarks.json?bookmarkable_type=${bookmarkableType}&bookmarkable_id=${bookmarkableId}`

  const { data, error, isLoading } = useSWR(bookmarkUrl, fetcher)
  if (error) console.log('error')
  if (isLoading) {
    return (
      <div
        id="bookmark-button"
        className="a-bookmark-button a-button is-sm is-block is-inactive is-muted">
        Bookmark
      </div>
    )
  }
  useEffect(() => {
    if (data) {
      setIsBookmark(data.bookmarks.length > 0)
      if (data.bookmarks.length > 0) {
        setIsBookmark(true)
      }
    }
  }, [data])

  if (data) {
    if (data.bookmarks.length > 0) {
      bookmarkId = data.bookmarks[0].id
    }
  }

  const bookmarkLabel = isBookmark ? 'Bookmark中' : 'Bookmark'
  const push = () => {
    if (isBookmark) {
      unbookmark()
    } else {
      bookmark()
    }
  }

  const bookmark = () => {
    Bootcamp.post(bookmarkUrl)
      .then(() => {
        setIsBookmark(true)
        toast.methods.toast('Bookmarkしました！')
      })
      .catch((error) => {
        console.warn(error)
      })
  }
  const unbookmark = () => {
    Bootcamp.delete(`/api/bookmarks/${bookmarkId}`)
      .then(() => {
        setIsBookmark(false)
        toast.methods.toast('Bookmarkを削除しました')
      })
      .catch((error) => {
        console.warn(error)
      })
  }
  return (
    <div
      id="bookmark-button"
      className={`a-bookmark-button a-button is-sm is-block ${
        isBookmark ? 'is-active is-main' : 'is-inactive is-muted'
      }`}
      onClick={() => push()}>
      {bookmarkLabel}
    </div>
  )
}

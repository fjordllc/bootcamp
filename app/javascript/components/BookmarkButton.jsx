import React, { useState, useEffect } from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import { post, destroy } from '@rails/request.js'
import { toast } from '../vanillaToast'

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

  const bookmark = async () => {
    try {
      const response = await post(bookmarkUrl, {
        contentType: 'application/json'
      })
      if (response.ok) {
        setIsBookmark(true)
        toast('Bookmarkしました！')
      } else {
        console.warn('Bookmarkに失敗しました。')
      }
    } catch (error) {
      console.warn(error)
    }
  }
  const unbookmark = async () => {
    try {
      const response = await destroy(`/api/bookmarks/${bookmarkId}`)
      if (response.ok) {
        setIsBookmark(false)
        toast('ブックマークを削除しました')
      } else {
        console.warn('ブックマーク削除に失敗しました。')
      }
    } catch (error) {
      console.warn(error)
    }
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

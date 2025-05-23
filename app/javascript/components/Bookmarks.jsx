import React, { useState, useEffect, useRef } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import fetcher from '../fetcher'
import { destroy } from '@rails/request.js'
import userIcon from '../user-icon.js'
import Pagination from './Pagination'
import usePage from './hooks/usePage'

export default function Bookmarks() {
  const [editable, setEditable] = useState(false)
  const per = 20
  const { page, setPage } = usePage()
  const bookmarksUrl = `/api/bookmarks.json?page=${page}&per=${per}`

  const { data, error } = useSWR(bookmarksUrl, fetcher)
  if (error) return <>エラーが発生しました。</>
  if (!data) return <>ロード中…</>

  if (data.totalPages === 0) {
    return <NoBookmarks />
  } else {
    return (
      <div data-testid="bookmarks">
        <div className="page-main">
          <div className="page-main-header">
            <div className="container">
              <div className="page-main-header__inner">
                <div className="page-main-header__start">
                  <h1 className="page-main-header__title">ブックマーク</h1>
                </div>
                <div className="page-main-header__end">
                  <div className="page-header-actions">
                    <div className="page-header-actions__items">
                      <div className="page-header-actions__item">
                        <div className="form-item is-inline">
                          <EditButton
                            editable={editable}
                            setEditable={setEditable}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          {/* .page-main-header */}
          <hr className="a-border"></hr>
          <div className="page-body">
            <div className="container is-md">
              {data.totalPages > 1 && (
                <Pagination
                  sum={data.totalPages * per}
                  per={per}
                  page={page}
                  setPage={setPage}
                />
              )}
              <div className="card-list a-card">
                <div className="card-list__items">
                  {data.bookmarks.map((bookmark) => {
                    return (
                      <Bookmark
                        key={bookmark.id}
                        bookmark={bookmark}
                        editable={editable}
                        setEditable={setEditable}
                        bookmarksUrl={bookmarksUrl}
                      />
                    )
                  })}
                </div>
              </div>
              {data.totalPages > 1 && (
                <Pagination
                  sum={data.totalPages * per}
                  per={per}
                  page={page}
                  setPage={setPage}
                />
              )}
            </div>
            {/* .container */}
          </div>
          {/* .page-body */}
        </div>
        {/* .page-main */}
      </div>
    )
  }
}

const NoBookmarks = () => {
  return (
    <div className="page-main">
      <div className="page-main-header">
        <div className="container">
          <div className="page-main-header__inner">
            <div className="page-main-header__start">
              <h1 className="page-main-header__title">ブックマーク</h1>
            </div>
          </div>
        </div>
      </div>
      {/* .page-main-header */}
      <hr className="a-border"></hr>
      <div className="page-body">
        <div className="o-empty-message">
          <div className="o-empty-message__icon">
            <i className="fa-regular fa-face-sad-tear" />
            <p className="o-empty-message__text">
              ブックマークはまだありません。
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

const EditButton = ({ editable, setEditable }) => {
  return (
    <>
      <label className="a-form-label" htmlFor="card-list-tools__action">
        編集
      </label>
      <label className="a-on-off-checkbox is-sm">
        <input
          id="card-list-tools__action"
          name="card-list-tools__action"
          type="checkbox"
          onChange={() => setEditable(!editable)}
          checked={editable}
        />
        <span id="spec-edit-mode" />
      </label>
    </>
  )
}

const Bookmark = ({ bookmark, editable, bookmarksUrl }) => {
  // userIconの非React化により、useRef,useEffectを導入している。
  const userIconRef = useRef(null)
  useEffect(() => {
    const linkClass = 'card-list-item__user-link'
    const imgClasses = ['card-list-item__user-icon', 'a-user-icon']

    const userIconElement = userIcon({
      user: bookmark.user,
      linkClass,
      imgClasses
    })

    if (userIconRef.current) {
      userIconRef.current.innerHTML = ''
      userIconRef.current.appendChild(userIconElement)
    }
  }, [bookmark.user])

  const date = bookmark.reported_on || bookmark.created_at
  // ISO8601日付を「YYYY年MM月DD日(曜日) HH:mm」形式に変換
  // タイムゾーンを考慮してUTCとして解釈し、日本時間での表示を行う
  const dateObj = new Date(date + (date.includes('T') ? '' : 'T00:00:00'))
  const year = dateObj.getFullYear()
  const month = String(dateObj.getMonth() + 1).padStart(2, '0')
  const day = String(dateObj.getDate()).padStart(2, '0')
  const weekday = dateObj.toLocaleDateString('ja-JP', { weekday: 'short' })
  const hours = String(dateObj.getHours()).padStart(2, '0')
  const minutes = String(dateObj.getMinutes()).padStart(2, '0')
  const createdAt = `${year}年${month}月${day}日(${weekday}) ${hours}:${minutes}`
  const { mutate } = useSWRConfig()
  const afterDelete = async (id) => {
    try {
      const response = await destroy(`/api/bookmarks/${id}.json`)
      if (response.ok) {
        mutate(bookmarksUrl)
      } else {
        console.warn('削除に失敗しました。')
      }
    } catch (error) {
      console.warn(error)
    }
  }

  return (
    <div className={'card-list-item is-' + bookmark.bookmark_class_name}>
      <div className="card-list-item__inner">
        {bookmark.modelName === 'Talk' ? (
          <div className="card-list-item__user" ref={userIconRef}></div>
        ) : (
          <div className="card-list-item__label">{bookmark.modelNameI18n}</div>
        )}
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              <div className="card-list-item-title__title">
                <a
                  href={bookmark.url}
                  className="card-list-item-title__link a-text-link">
                  {bookmark.title}
                </a>
              </div>
            </div>
          </div>
          {bookmark.modelName !== 'Talk' && (
            <div>
              <div className="card-list-item__row">
                <div className="card-list-item__summary">
                  <p>{bookmark.summary}</p>
                </div>
              </div>
              <div className="card-list-item__row">
                <div className="card-list-item-meta">
                  <div className="card-list-item-meta__item">
                    <a href={bookmark.authorUrl} className="a-user-name">
                      {bookmark.authorLoginName}({bookmark.authorNameKana})
                    </a>
                  </div>
                  <div className="card-list-item-meta__item">
                    <time className="a-meta" dateTime={bookmark.updated_at}>
                      {createdAt}
                    </time>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
        {editable && (
          <DeleteButton id={bookmark.id} afterDelete={afterDelete} />
        )}
      </div>
    </div>
  )
}

const DeleteButton = ({ id, afterDelete }) => {
  return (
    <div className="card-list-item__option">
      <div
        className="bookmark-delete-button a-bookmark-button a-button is-sm is-block is-main"
        onClick={() => afterDelete(id)}>
        削除
      </div>
    </div>
  )
}

import React, { useState, useEffect, useRef } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import fetcher from '../fetcher'
import { destroy } from '@rails/request.js'
import userIcon from '../user-icon.js'
import { toast } from '../toast_react'
import { formatDateToJapanese } from '../dateFormatter'

export default function BookmarksInDashboard() {
  const [editable, setEditable] = useState(false)
  const per = 5
  const bookmarksUrl = `/api/bookmarks.json?&per=${per}`

  const { data, error } = useSWR(bookmarksUrl, fetcher)
  if (error) return <>エラーが発生しました。</>
  if (!data) return <>ロード中…</>

  if (data.unpagedBookmarks.length === 0) {
    const bookmarksDomNode = document.getElementById('bookmarks-in-dashboard')
    bookmarksDomNode.classList.add('hidden')
  }

  return (
    <div className="a-card">
      <header className="card-header is-sm">
        <h2 className="card-header__title">最新のブックマーク</h2>
        <div className="card-header__action">
          <EditButton editable={editable} setEditable={setEditable} />
          <span></span>
        </div>
      </header>
      <hr className="a-border-tint" />
      <div className="card-list">
        {data.bookmarks.map((bookmark) => {
          return (
            <Bookmark
              key={bookmark.id}
              bookmark={bookmark}
              editable={editable}
              bookmarksUrl={bookmarksUrl}
            />
          )
        })}
      </div>
      <footer className="card-footer">
        <div className="card-footer__footer-link">
          <a
            href={`current_user/bookmarks`}
            className="card-footer__footer-text-link">
            全てのブックマーク（{data.unpagedBookmarks.length}）
          </a>
        </div>
      </footer>
    </div>
  )
}

const EditButton = ({ editable, setEditable }) => {
  return (
    <>
      <label
        className="a-form-label is-sm is-inline spec-bookmark-edit"
        htmlFor="card-list-tools__action">
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
  const createdAt = formatDateToJapanese(date)
  const { mutate } = useSWRConfig()
  const afterDelete = async (id) => {
    try {
      const response = await destroy(`/api/bookmarks/${id}.json`)
      if (response.ok) {
        mutate(bookmarksUrl)
        toast('ブックマークを削除しました。')
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
        className="card-list-item__option js-bookmark-delete-button a-button is-sm is-primary"
        onClick={() => afterDelete(id)}>
        削除
      </div>
    </div>
  )
}

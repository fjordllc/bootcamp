import React, { useState } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import fetcher from '../fetcher'
import Bootcamp from '../bootcamp'
import UserIcon from './UserIcon'
import usePage from './hooks/usePage'

export default function Bookmarks({ bookmarksNum }) {
  const [editable, setEditable] = useState(false)
  const per = 5
  const { page } = usePage()
  const bookmarksUrl = `/api/bookmarks.json?page=${page}&per=${per}`

  const { data, error } = useSWR(bookmarksUrl, fetcher)
  if (error) return <>エラーが発生しました。</>
  if (!data) return <>ロード中…</>

  return (
    <div class="a-card">
      <header class="card-header is-sm">
        <h2 class="card-header__title">最新のブックマーク</h2>
        <div class="card-header__action">
          <EditButton editable={editable} setEditable={setEditable} />
          <span></span>
        </div>
      </header>
      <hr class="a-border-tint" />
      <div class="card-list">
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
      <footer class="card-footer">
        <div class="card-footer__footer-link">
          <a
            href={`current_user/bookmarks`}
            class="card-footer__footer-text-link">
            全てのブックマーク（{bookmarksNum}）
          </a>
        </div>
      </footer>
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

const Bookmark = ({ bookmark, editable, bookmarksUrl, _setEditable }) => {
  const date = bookmark.reported_on || bookmark.created_at
  const createdAt = Bootcamp.iso8601ToFullTime(date)
  const { mutate } = useSWRConfig()
  const afterDelete = (id) => {
    Bootcamp.delete(`/api/bookmarks/${id}.json`)
      .then((_response) => {
        mutate(bookmarksUrl)
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className={'card-list-item is-' + bookmark.bookmark_class_name}>
      <div className="card-list-item__inner">
        {bookmark.modelName === 'Talk' ? (
          <div className="card-list-item__user">
            <UserIcon user={bookmark.user} blockClassSuffix="card-list-item" />
          </div>
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

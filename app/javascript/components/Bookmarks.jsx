import React, { useState, useEffect } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import fetcher from '../fetcher'
import Bootcamp from '../bootcamp'

export default function Bookmarks() {
  const [editable, setEditable] = useState(false);
  const { data, error } = useSWR(`/api/bookmarks.json`, fetcher)
  if (error) return <>エラーが発生しました。</>
  if (!data) return <>ロード中…</>

  return (
    <>
      <div className="card-list-tools">
        <div className="form-item is-inline">
          <EditButton editable={editable} setEditable={setEditable} />
        </div>
      </div>
      <div className="card-list a-card">
        <div className="card-list__items">
          {data.bookmarks.map((bookmark) => {
            return (
              <Bookmark
                key={bookmark.id}
                bookmark={bookmark}
                editable={editable}
                setEditable={setEditable}
              />
            )
          })}
        </div>
      </div>
    </>
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

const Bookmark = ({ bookmark, editable, setEditable }) => {
  const date = bookmark.reported_on || bookmark.created_at
  const createdAt = Bootcamp.iso8601ToFullTime(date)
  const { mutate } = useSWRConfig()
  const afterDelete = (id) => {
    Bootcamp.delete(`/api/bookmarks/${id}.json`)
      .then((response) => {
        mutate('/api/bookmarks.json')
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className={'card-list-item is-' + bookmark.bookmark_class_name}>
      <div className="card-list-item__inner">
        <div className="card-list-item__label">{bookmark.modelNameI18n}</div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              <div className="card-list-item-title__title">
                <a href={bookmark.url} className="card-list-item-title__link a-text-link">
                  {bookmark.title}
                </a>
              </div>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item__summary">
              <p>{bookmark.summary}</p>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__item">
                <a href={bookmark.authorUrl} className="a-user-name">{bookmark.author}</a>
              </div>
              <div className="card-list-item-meta__item">
                <time className="a-meta" dateTime={bookmark.updated_at}>
                  {createdAt}
                </time>
              </div>
            </div>
          </div>
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
        id="bookmark-button"
        className="a-bookmark-button a-button is-sm is-block is-main"
        onClick={() => afterDelete(id)}
      >
        削除
      </div>
    </div>
  )
}

import React, { useState } from 'react'
import toast from '../../toast'
import CSRF from '../../csrf'

export default function TagEditModal({ tagId, initialTagName, setShowModal }) {
  const [tagName, setTagName] = useState(initialTagName)

  const cancel = () => {
    setShowModal(false)
    setTagName(initialTagName)
  }

  const updateTagList = () => {
    // 変更した内容を反映するためにリクエストを送り直している。
    // 変更内容を反映したい箇所がslimで書かれているため。
    location.href = location.pathname.replace(
      `/tags/${encodeURIComponent(initialTagName)}`,
      `/tags/${encodeURIComponent(tagName)}`
    )
  }

  const updateTag = () => {
    fetch(`/api/tags/${tagId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify({ tag: { name: tagName } })
    })
      .then(() => {
        toast.methods.toast('タグ名を変更しました')
        updateTagList()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className="a-overlay is-js">
      <div className="a-card is-modal">
        <header className="card-header is-sm">
          <h2 className="card-header__title">タグ名変更</h2>
        </header>
        <hr className="a-border-shade"></hr>
        <div className="card-body">
          <div className="card__description">
            <label className="a-form-label" htmlFor="tag_name">
              タグ名
            </label>
            <input
              id="tag_name"
              className="a-text-input"
              value={tagName}
              onChange={(e) => setTagName(e.target.value)}
              name="tag[name]"
            />
          </div>
        </div>
        <footer className="card-footer">
          <div className="card-main-actions">
            <ul className="card-main-actions__items">
              <li className="card-main-actions__item is-main">
                <button
                  className="a-button is-primary is-sm is-block"
                  disabled={tagName === initialTagName || tagName === ''}
                  onClick={updateTag}>
                  変更
                </button>
              </li>
              <li className="card-main-actions__item is-sub">
                <div
                  className="card-main-actions__muted-action"
                  onClick={cancel}>
                  キャンセル
                </div>
              </li>
            </ul>
          </div>
        </footer>
      </div>
    </div>
  )
}
